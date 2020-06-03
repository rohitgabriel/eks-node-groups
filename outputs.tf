output "nodegroup_status" {
  description = "Nodegroup Status"
  value       = "${module.nodegroup.nodegroup_status}"
}

output "nodegroup_id" {
  description = "Nodegroup name"
  value       = "${module.nodegroup.nodegroup_id}"
}
output "certificate_authority" {
  description = "Use for kubeconfig"
  value       = "${module.cluster.certificate_authority}"
}

output "endpoint" {
  description = "EKS endpoint"
  value       = "${module.cluster.endpoint}"
}
