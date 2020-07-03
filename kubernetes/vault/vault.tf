resource "tls_private_key" "eit_ca" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_self_signed_cert" "eit_ca" {
  key_algorithm     = "RSA"
  private_key_pem   = tls_private_key.eit_ca.private_key_pem
  is_ca_certificate = true

  subject {
    common_name         = "eit.com"
    organization        = "EIT Self Signed"
    organizational_unit = "EIT"
  }

  validity_period_hours = 876590

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]
}

resource "tls_private_key" "example_com" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_cert_request" "example_com" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.example_com.private_key_pem

  dns_names = ["server.dc1.cluster.local"]

  subject {
    common_name         = "localhost"
    organization        = "EIT"
    country             = "NZ"
    organizational_unit = "EITI"
  }
}

resource "tls_locally_signed_cert" "example_com" {
  cert_request_pem   = tls_cert_request.example_com.cert_request_pem
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = tls_private_key.eit_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.eit_ca.cert_pem

  validity_period_hours = 87659

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}


resource "aws_kms_key" "vault" {
  description             = "Vault auto-unseal key"
  deletion_window_in_days = 10
}

resource "kubernetes_secret" "vault" {
  metadata {
    name = "vault"
    namespace = "vault"
  }

  data = {
    "ca.pem"        = tls_self_signed_cert.eit_ca.cert_pem
    "consul-key.pem" = tls_private_key.example_com.private_key_pem
    "consul.pem"     = tls_locally_signed_cert.example_com.cert_pem
  }

#   depends_on = ["kubernetes_stateful_set.consul"]
}

# VAULT CONFIGMAP
data "template_file" "vault_config" {
  template = <<VAULTCONFIG
{
  "listener": {
    "tcp":{
      "address": "127.0.0.1:8200",
      "tls_disable": 0,
      "tls_cert_file": "/etc/tls/vault.pem",
      "tls_key_file": "/etc/tls/vault-key.pem"
    }
  },
  "seal": {
    "awskms": {
      "region": "${var.AWS_REGION}",
      "kms_key_id": "${aws_kms_key.vault.id}"
    }
  },
  "storage": {
    "consul": {
      "address": "consul:8500",
      "path": "vault/",
      "disable_registration": "true",
      "ha_enabled": "true"
    }
  },
  "ui": true
}
VAULTCONFIG
}

resource "kubernetes_config_map" "vault" {
  metadata {
    name = "vault"
    namespace = "vault"
  }

  data = {
    "config.json" = data.template_file.vault_config.rendered
  }
}

# VAULT SERVICE
resource "kubernetes_service" "vault" {
  metadata {
    name = "vault"
    namespace = "vault"

    labels = {
      app = "vault"
    }
  }

  spec {
    type = "ClusterIP"

    port {
      port        = 8200
      target_port = 8200
      name        = "vault"
    }

    selector = {
      app = "vault"
    }
  }

  depends_on = [kubernetes_config_map.vault]
}

# VAULT DEPLOYMENT

# resource "kubernetes_persistent_volume_claim" "vault_config" {
#   metadata {
#     name = "vaultconfig"
#     namespace = "vault"
#   }
#   spec {
#     access_modes = ["ReadWriteMany"]
#     resources {
#       requests = {
#         storage = "1Gi"
#       }
#     }
#     storage_class_name = "efs-sc"
#     volume_name = "efs-pv-vaultconfig"
#   }
# }

resource "kubernetes_deployment" "vault" {
  metadata {
    name = "vault"
    namespace = "vault"

    labels = {
      app = "vault"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "vault"
      }
    }

    template {
      metadata {
        labels = {
          app = "vault"
        }
      }

      spec {
        container {
          name              = "vault"
          command           = ["vault", "server", "-config", "/efs-consulconfig/vault/config/config.json"]
          image             = "vault:1.4.2"
          image_pull_policy = "IfNotPresent"

          security_context {
            capabilities {
              add = ["IPC_LOCK"]
            }
          }

          volume_mount {
            name       = "configurations"
            mount_path = "/efs-consulconfig/vault/config/config.json"
            sub_path   = "config.json"
          }

          volume_mount {
            name       = "vault"
            mount_path = "/etc/tls"
          }
        }

        container {
          name  = "consul-vault-agent"
          image = "consul:1.8.0"

          env {
            name = "GOSSIP_ENCRYPTION_KEY"

            value_from {
              secret_key_ref {
                name = "consul"
                key  = "gossip-encryption-key"
              }
            }
          }

          env {
            name = "NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          args = ["agent", "-retry-join=consul-0.consul.$(NAMESPACE).svc.cluster.local", "-retry-join=consul-1.consul.$(NAMESPACE).svc.cluster.local", "-retry-join=consul-2.consul.$(NAMESPACE).svc.cluster.local", "-encrypt=$(GOSSIP_ENCRYPTION_KEY)", "-domain=cluster.local", "-datacenter=dc1", "-disable-host-node-id", "-node=vault-1"]

          volume_mount {
            name       = "config"
            mount_path = "/consul/myconfig"
          }

          volume_mount {
            name       = "tls"
            mount_path = "/etc/tls"
          }
        }

        volume {
          name = "configurations"

          config_map {
            name = "vault"
          }
        }

        volume {
          name = "config"

          config_map {
            name = "consul"
          }
        }

        volume {
          name = "tls"

          secret {
            secret_name = "consul"
          }
        }

        volume {
          name = "vault"

          secret {
            secret_name = "vault"
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service.vault]
}
