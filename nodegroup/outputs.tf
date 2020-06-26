output "nodegroup_id" {
  value = aws_eks_node_group.node_group.id
}

output "nodegroup_status" {
  value = aws_eks_node_group.node_group.status
}

output "iam_instance_arn" {
  value = aws_iam_role.eks_nodegroup_role.arn
}