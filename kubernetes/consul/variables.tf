variable "kube_depends_on" {
  description = "Dummy variable to invoke dependency"
  type        = list
}

variable "app_name" {
  type        = string
  description = "Name of the application"
}

# variable "aws_auth" {
#   type        = string
#   description = "aws auth"
# }