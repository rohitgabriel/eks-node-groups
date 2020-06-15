resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
#   repository = "https://kubernetes-charts.storage.googleapis.com"
#   chart      = "aws-cluster-autoscaler"
  chart = "./helm/cluster-autoscaler/aws-cluster-autoscaler"
  namespace  = "kube-system"
  version    = "0.3.3"

#   set {
#     name  = "autoDiscovery.enabled"
#     value = "true"
#   }

  set {
    name  = "autoDiscovery.clusterName"
    value = var.app_name
  }

#   set {
#     name  = "cloudProvider"
#     value = "aws"
#   }

#   set {
#     name  = "awsRegion"
#     value = var.AWS_REGION
#   }

#   set {
#     name  = "rbac.create"
#     value = "true"
#   }

#   set {
#     name  = "sslCertPath"
#     value = "/etc/ssl/certs/ca-certificates.crt"
#   }
}