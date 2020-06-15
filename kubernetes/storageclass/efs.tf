resource "kubernetes_storage_class" "efs" {
  metadata {
    name = "efs-sc"
  }
  storage_provisioner = "efs.csi.aws.com"
  reclaim_policy      = "Retain"
}

# There is currently no persistent volume source available for EFS as terraform resource
# resource "kubernetes_persistent_volume" "efs-pv" {
#   metadata {
#     name = "efs-pv"
#   }
#   spec {
#     capacity = {
#       storage = "2Gi"
#     }
#     access_modes = ["ReadWriteMany"]
#     persistent_volume_reclaim_policy = "Retain"
#     storage_class_name = "efs-sc"
#     persistent_volume_source {
#       vsphere_volume {
#         volume_path = "/absolute/path"
#       }
#     }
#     # csi = {
#     #     driver = "efs.csi.aws.com"
#     #     volumeHandle = var.efs_volumehandle
#     # }
#   }
# }
