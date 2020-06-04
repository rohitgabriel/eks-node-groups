output "nodegroup_id" {
  value = aws_eks_node_group.node_group.id
}

output "nodegroup_status" {
  value = aws_eks_node_group.node_group.status
}