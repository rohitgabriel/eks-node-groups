variable "AWS_REGION" {
  description = "Set the AWS region"
  type        = string
}

variable "kube_depends_on" {
  description = "Dummy variable to invoke dependency"
  type        = list
}