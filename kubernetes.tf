# provider "kubernetes" {
#   host                   = module.cluster.endpoint
#   token                  = module.cluster.cluster_token
#   cluster_ca_certificate = base64decode(module.cluster.certificate_authority)
#   load_config_file       = false
# }