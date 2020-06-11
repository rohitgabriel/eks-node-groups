provider "helm" {
  version = "~>1.2.2"
  debug   = true
  # alias   = "helm"

  kubernetes {
    host                   = module.cluster.endpoint
    token                  = module.cluster.cluster_token
    cluster_ca_certificate = base64decode(module.cluster.certificate_authority)
    load_config_file       = false
  }
}

# resource "helm_release" "mydatabase" {
#   provider  = helm.helm
#   name      = "mydatabase"
#   chart     = "mariadb"
#   namespace = "default"
#   repository = "https://kubernetes-charts.storage.googleapis.com"

#   set {
#     name  = "mariadbUser"
#     value = "foooo"
#   }

#   set {
#     name  = "mariadbPassword"
#     value = "qux"
#   }
# }