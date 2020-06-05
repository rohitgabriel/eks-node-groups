variable availability_zones {
  type        = list(string)
  default     = ["a", "b", "c"]
  description = "List of AWS Availability Zone suffixes"
}

variable vpc_cidr {
  type        = string
  description = "CIDR range to assign to the VPC"
}

variable "AWS_REGION" {
  default     = "ap-southeast-2"
  description = "Set the AWS region"
  type        = string
}

variable "app_name" {
  type        = string
  description = "Name of the application"
}

variable "app_name2" {
  type        = string
  description = "Name of the application"
}