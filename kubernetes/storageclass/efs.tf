resource "kubernetes_storage_class" "efs" {
  metadata {
    name = "efs-sc"
  }
  storage_provisioner = "efs.csi.aws.com"
  reclaim_policy      = "Retain"
}

# There is currently no persistent volume source available for EFS as terraform resource
resource "kubernetes_persistent_volume" "efs-pv" {
  metadata {
    name = "efs-pv"
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
        path   = "/efs"
      }
    }
  }
}

resource "kubernetes_persistent_volume" "efs-pv-consulconfig" {
  metadata {
    name = "efs-pv-consulconfig"
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
        path   = "/efs-consulconfig"
      }
    }
  }
}