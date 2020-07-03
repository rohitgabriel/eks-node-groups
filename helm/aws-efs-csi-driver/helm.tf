resource "helm_release" "efs_driver" {
  # provider  = helm
  name      = "aws-efs-csi-driver"
  chart     = "${path.module}/helm"
  namespace = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"

}