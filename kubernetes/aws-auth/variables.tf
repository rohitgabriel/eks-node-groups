variable "iam_instance_arn" {
  description = "ARN of the instance"
  type        = string
}

variable "kube_depends_on" {
  description = "Dummy variable to invoke dependency"
  type        = list
}

variable "aws_account_id" {
  description = "AWS account id"
  type        = string
}

variable "aws_devops_user" {
  description = "AWS devops user"
  type        = string
}

