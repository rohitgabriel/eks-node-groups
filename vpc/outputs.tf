

# output "subnet_cidr_blocks" {
#   value = [for s in data.aws_subnet.all : s.cidr_block]
# }

output "id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc_network_VPC.id
#   value       = concat(aws_vpc.vpc_network_VPC.*.id, [""])[0]
}

output "cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.vpc_network_VPC.cidr_block
#   value       = concat(aws_vpc.vpc_network_VPC.*.cidr_block, [""])[0]
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private.*.id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public.*.id
}

output "lb_security_group_id" {
  description = "The ID of the loadbalancer security group"
  value       = aws_security_group.loadbalancer.id
}

output "db_security_group_id" {
  description = "The ID of the db security group"
  value       = aws_security_group.postgresdb.id
}

output "egress_security_group_id" {
  description = "The ID of the egress security group"
  value       = aws_security_group.egress.id
}

output "appserver_security_group_id" {
  description = "The ID of the appserver security group"
  value       = aws_security_group.appserver.id
}

