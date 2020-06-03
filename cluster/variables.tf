
variable "app_name" {
  type        = string
  default     = "eks"
  description = "Name of the application"
}

variable "eks_version" {
  type        = string
  default     = "1.16"
  description = "EKS version"
}

variable "private_subnet_ids" {
  description = "EKS version"
}

variable "id" {
  description = "VPC ID"
}