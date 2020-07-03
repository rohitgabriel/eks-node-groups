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

resource "kubernetes_namespace" "consul" {
  metadata {
    name = "vault"
    annotations = {
      name = "consul"
    }

    labels = {
      name = "consul"
    }
  }
}


resource "kubernetes_secret" "consul" {
  metadata {
    name = "consul"
    namespace = "vault"
  }

  data = {
    "ca.pem"        = tls_self_signed_cert.eit_ca.cert_pem
    "consul-key.pem" = tls_private_key.example_com.private_key_pem
    "consul.pem"     = tls_locally_signed_cert.example_com.cert_pem

    gossip-encryption-key = "pUqJrVyVRj5jsiYEkM/tFQYfWyJIv4s3XkvDwy7Cu5s="
  }

#   depends_on = [module.kubernetes.aws-auth]
}

# CONSUL CONFIGMAP
data "template_file" "consul_config" {
  template = <<CONSULCONFIG
{
  "ca_file": "/etc/tls/ca.pem",
  "cert_file": "/etc/tls/consul.pem",
  "key_file": "/etc/tls/consul-key.pem",
  "verify_incoming": true,
  "verify_outgoing": true,
  "verify_server_hostname": true,
  "ports": {
    "https": 8443
  }
}
CONSULCONFIG
}

resource "kubernetes_config_map" "consul" {
  metadata {
    name = "consul"
    namespace = "vault"
  }

  data = {
    "config.json" = data.template_file.consul_config.rendered
  }

#   depends_on = [var.aws_auth]
}

# resource "kubernetes_persistent_volume_claim" "consul_config" {
#   metadata {
#     name = "consulconfig"
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
#     volume_name = "efs-pv-consulconfig"
#   }
# }
# resource "kubernetes_persistent_volume_claim" "consul_tls" {
#   metadata {
#     name = "consultlscerts"
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
#     volume_name = "efs-pv"
#   }
# }


resource "kubernetes_persistent_volume" "efs-pv-consul-data" {
  metadata {
    name = "efs-pv-consul-data"
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name = "efs-sc"
    persistent_volume_source {
      nfs {
        server = "fs-1600ec2e.efs.ap-southeast-2.amazonaws.com"
        path   = "/consul/data"
      }
    }
  }
}
resource "kubernetes_persistent_volume_claim" "consul_data" {
  metadata {
    name = "consul-data"
    namespace = "vault"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }

    storage_class_name = var.efs_sc_name
    volume_name = kubernetes_persistent_volume.efs-pv-consul-data.metadata[0].name
  }
}
# CONSUL SERVICE to expose each of the Consul members internally
resource "kubernetes_service" "consul" {
  metadata {
    name = "consul"
    namespace = "vault"
    labels = {
      name = "consul"
    }
  }

  spec {
    selector = {
      app = "consul"
    }

    cluster_ip = "None" # Headless service

    port  {
      name        = "http"
      port        = 8500
      target_port = 8500
    }

    port  {
      name        = "https"
      port        = 8443
      target_port = 8443
    }

    port  {
      name        = "rpc"
      port        = 8400
      target_port = 8400
    }

    port  {
      name        = "serflan-tcp"
      port        = 8301
      target_port = 8301
    }

    port  {
      name        = "serfwan-tcp"
      port        = 8302
      target_port = 8302
    }

    port  {
      name        = "serflan-udp"
      protocol    = "UDP"
      port        = 8301
      target_port = 8301
    }

    port  {
      name        = "serfwan-udp"
      protocol    = "UDP"
      port        = 8302
      target_port = 8302
    }

    port  {
      name        = "server"
      port        = 8300
      target_port = 8300
    }

    port  {
      name        = "consuldns"
      port        = 8600
      target_port = 8600
    }
  }
}

## CONSUL STATEFULSET
resource "kubernetes_stateful_set" "consul" {
  metadata {
    name = "consul"
    namespace = "vault"
  }

  spec {
    service_name = "consul"
    replicas     = 3

    selector {
      match_labels = {
        app = "consul"
      }
    }

    template {
      metadata {
        labels = {
          app = "consul"
        }

        annotations = {}
      }

      spec {
        security_context {
          fs_group = 1000
        }

        container {
          name  = "consul"
          image = "consul:1.8.0"

          env {
            name = "POD_IP"

            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }

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

          args = ["agent", "-advertise=$(POD_IP)", "-bind=0.0.0.0", "-bootstrap-expect=3", "-retry-join=consul-0.consul.$(NAMESPACE).svc.cluster.local", "-retry-join=consul-1.consul.$(NAMESPACE).svc.cluster.local", "-retry-join=consul-2.consul.$(NAMESPACE).svc.cluster.local", "-client=0.0.0.0", "-config-file=/efs-consulconfig/consul/consulconfig/config.json", "-datacenter=dc1", "-data-dir=/consul/data", "-domain=cluster.local", "-encrypt=$(GOSSIP_ENCRYPTION_KEY)", "-server", "-ui", "-disable-host-node-id"]

          volume_mount {
            name       = "config"
            mount_path = "/efs-consulconfig/consul/consulconfig"
          }

          volume_mount {
            name       = "consul-data"
            mount_path = "/consul/data"
          }

          volume_mount {
            name       = "tls"
            mount_path = "/etc/tls"
          }

          lifecycle {
            pre_stop {
              exec {
                command = ["/bin/sh", "-c", "consul leave"]
              }
            }
          }

          port {
            container_port = 8500
            name           = "ui-port"
          }

          port {
            container_port = 8400
            name           = "alt-port"
          }

          port {
            container_port = 53
            name           = "udp-port"
          }

          port {
            container_port = 8443
            name           = "https-port"
          }

          port {
            container_port = 8080
            name           = "http-port"
          }

          port {
            container_port = 8301
            name           = "serflan"
          }

          port {
            container_port = 8302
            name           = "serfwan"
          }

          port {
            container_port = 8600
            name           = "consuldns"
          }

          port {
            container_port = 8300
            name           = "server"
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
          name = "consul-data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.consul_data.metadata[0].name
          }
        }
      }
    }
    # volume_claim_template {
    #   metadata {
    #     name = "consul-data"
    #   }

    #   spec {
    #     access_modes       = ["ReadWriteMany"]
    #     storage_class_name = "efs-sc"
    #     volume_name = "efs-pv-consul-data"

    #     resources {
    #       requests = {
    #         storage = "4Gi"
    #       }
    #     }
    #   }
    # }
  }

  depends_on = [kubernetes_service.consul]
}
