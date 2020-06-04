# output "nodegroup_status" {
#   description = "Nodegroup Status"
#   value       = module.nodegroup.nodegroup_status
# }

# output "nodegroup_id" {
#   description = "Nodegroup name"
#   value       = module.nodegroup.nodegroup_id
# }
# output "certificate_authority" {
#   description = "Use for kubeconfig"
#   value       = module.cluster.certificate_authority
# }

# output "endpoint" {
#   description = "EKS endpoint"
#   value       = module.cluster.endpoint
# }


# output "publicsubnets_security_group_id" {
#   description = "The ID of the public subnet security group"
#   value       = aws_security_group.public_subnets.id
# }

# output "privatesubnets_security_group_id" {
#   description = "The ID of the private subnet security group"
#   value       = aws_security_group.private_subnets.id
# }

# output "egress_security_group_id" {
#   description = "The ID of the egress security group"
#   value       = aws_security_group.egress.id
# }