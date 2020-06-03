
variable "app_name" {
  type        = string
  description = "Name of the application"
}

variable "eks_version" {
  type        = string
  description = "EKS version"
}

variable "private_subnet_ids" {
  description = "Private Subnet IDs"
  type        = list
}

variable "id" {
  description = "VPC ID"
  type        = string
}