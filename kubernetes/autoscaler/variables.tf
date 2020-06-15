variable "app_name" {
  type        = string
  description = "Name of the application"
}

variable "AWS_REGION" {
  description = "Set the AWS region"
  type        = string
}

variable "autoscaler_version" {
  description = "Set the Autoscaler version"
  type        = string
}