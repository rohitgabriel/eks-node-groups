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

variable "kube_depends_on" {
  description = "Dummy variable to invoke dependency"
  type        = list
}