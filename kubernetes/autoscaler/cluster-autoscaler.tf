resource "kubernetes_service_account" "autoscaler" {
  metadata {
    labels = {
    k8s-addon = "cluster-autoscaler.addons.k8s.io"
    k8s-app = "cluster-autoscaler"
    }
  name = "cluster-autoscaler"
  namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role" "autoscaler" {
  metadata {
    name = "cluster-autoscaler"
    labels = {
    k8s-addon= "cluster-autoscaler.addons.k8s.io"
    k8s-app= "cluster-autoscaler"
    }
  }
  rule {
    api_groups = [""]
    resources  = ["events", "endpoints"]
    verbs      = ["create", "patch"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/eviction"]
    verbs      = ["create"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/status"]
    verbs      = ["update"]
  }
  rule {
    api_groups = [""]
    resources  = ["endpoints"]
    resource_names = ["cluster-autoscaler"]
    verbs      = ["get","update"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["watch", "list", "get", "update"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods","services","replicationcontrollers","persistentvolumeclaims","persistentvolumes"]
    verbs      = ["watch", "list", "get"]
  }
  rule {
    api_groups = ["extensions"]
    resources  = ["replicasets", "daemonsets"]
    verbs      = ["watch", "list", "get"]
  }
  rule {
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
    verbs      = ["watch", "list"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["statefulsets", "replicasets", "daemonsets"]
    verbs      = ["watch", "list", "get"]
  }
  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses", "csinodes"]
    verbs      = ["watch", "list", "get"]
  }
  rule {
    api_groups = ["batch", "extensions"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "watch", "patch"]
  }
  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["create"]
  }
  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    resource_names = ["cluster-autoscaler"]
    verbs      = ["get", "update"]
  }
}

resource "kubernetes_role" "autoscaler" {
  metadata {
    name = "cluster-autoscaler"
    namespace= "kube-system"
    labels = {
    k8s-addon = "cluster-autoscaler.addons.k8s.io"
    k8s-app = "cluster-autoscaler"
    }
  }

  rule {
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["cluster-autoscaler-status", "cluster-autoscaler-priority-expander"]
    verbs          = ["delete", "get", "update", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["create","list","watch"]
  }
}

resource "kubernetes_cluster_role_binding" "autoscaler" {
  metadata {
    name = "cluster-autoscaler"
    
    labels = {
    k8s-addon = "cluster-autoscaler.addons.k8s.io"
    k8s-app = "cluster-autoscaler"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-autoscaler"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cluster-autoscaler"
    namespace = "kube-system"
  }
}

resource "kubernetes_role_binding" "autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    labels = {
    k8s-addon = "cluster-autoscaler.addons.k8s.io"
    k8s-app = "cluster-autoscaler"
    }
    namespace = "kube-system"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "cluster-autoscaler"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cluster-autoscaler"
    namespace = "kube-system"
  }
}

resource "kubernetes_deployment" "autoscaler" {
  metadata {
    name = "cluster-autoscaler"
    namespace = "kube-system"
    labels = {
      app = "cluster-autoscaler"
    }
  }

  spec {

    replicas = 1

    selector {
      match_labels = {
        app = "cluster-autoscaler"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "cluster-autoscaler"
        }
        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port"   = "8085"
          "cluster-autoscaler.kubernetes.io/safe-to-evict" = "false"
        }
      }

      spec {
        service_account_name = "cluster-autoscaler"
        automount_service_account_token = "true"
        container {
          image = var.autoscaler_version
          name  = "cluster-autoscaler"

          resources {
            limits {
              cpu    = "100m"
              memory = "300Mi"
            }
            requests {
              cpu    = "100m"
              memory = "300Mi"
            }
          }
          command = [
            "./cluster-autoscaler",
            "--v=4",
            "--stderrthreshold=info",
            "--cloud-provider=aws",
            "--skip-nodes-with-local-storage=false",
            "--expander=least-waste",
            "--node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/${var.app_name}",
            "--balance-similar-node-groups",
            "--skip-nodes-with-system-pods=false"
          ]
          volume_mount {
              name = "ssl-certs"
              mount_path = "/etc/ssl/certs/ca-certificates.crt"
              read_only = "true"
          }
        }
        volume {
            name = "ssl-certs"
            host_path  {
                path = "/etc/ssl/certs/ca-bundle.crt"
            }
        }
      }
    }
  }
}
