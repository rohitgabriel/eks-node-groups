variable "AWS_REGION" {
  default     = "ap-southeast-2"
  description = "Set the AWS region"
  type        = string
}

variable "instance_type" {
  default     = "t2.micro"
  description = "Set the EC2 Instance type"
  type        = string
}

variable "ebs_device_name" {
  default     = "/dev/xvdz"
  description = "Set the EBS device name"
  type        = string
}

variable "ebs_volume_type" {
  default     = "gp2"
  description = "Set the EBS volume type"
  type        = string
}

variable "ebs_volume_size" {
  default     = "50"
  description = "Set the EBS volume size in GB"
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

