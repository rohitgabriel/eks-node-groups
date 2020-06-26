resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

   data = {
    mapRoles = <<YAML
- rolearn: ${var.iam_instance_arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
YAML
    mapUsers = <<YAML2
- userarn: arn:aws:iam::${var.aws_account_id}:user/${var.aws_devops_user}
  username: ${var.aws_devops_user}
  groups:
    - system:masters
YAML2
   }
}