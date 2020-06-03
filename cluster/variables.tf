
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