
variable "app_name" {
  type        = string
  description = "Name of the application"
}

variable "cluster_name" {
  type        = string
  description = "Name of the application"
}

variable "instance_type" {
  description = "Set the EC2 Instance type"
  type        = list
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list
}

variable "id" {
  description = "VPC ID"
  type        = string
}

variable "ebs_volume_size" {
  description = "Set the EBS volume size in GB"
  type        = string
}

variable "nodegroup_ami_version" {
  description = "Node group version listed by AWS"
  type        = string
}
