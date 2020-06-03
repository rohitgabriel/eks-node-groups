variable availability_zones {
  type        = list(string)
  default     = ["a", "b", "c"]
  description = "List of AWS Availability Zone suffixes"
}

variable vpc_cidr {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR range to assign to the VPC"
}

variable "AWS_REGION" {
  default     = "ap-southeast-2"
  description = "Set the AWS region"
  type        = string
}

variable "lb_port" {
  default     = 3000
  description = "Set the EBS volume size in GB"
  type        = number
}

variable "app_port" {
  default     = 3000
  description = "Set the EBS volume size in GB"
  type        = number
}

variable "db_port" {
  default     = "5432"
  description = "Set the RDS port number"
  type        = number
}

variable "app_name" {
  type        = string
  default     = "eks"
  description = "Name of the application"
}
