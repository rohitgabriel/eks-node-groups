variable "AWS_REGION" {
  default     = "ap-southeast-2"
  description = "Set the AWS region"
  type        = string
}

variable "instance_type" {
  default     = ["t3.medium"]
  description = "Set the EC2 Instance type"
  type        = list
}

variable "ebs_volume_size" {
  default     = "50"
  description = "Set the EBS volume size in GB"
  type        = string
}

variable "app_name" {
  type        = string
  default     = "eks"
  description = "Name of the application"
}

variable "eks_version" {
  type = string
  default     = "1.16"
  # default     = "1.15"
  description = "EKS version"
}

variable "nodegroup_ami_version" {
  type = string
  default     = "1.16.8-20200507"
  # default     = "1.15.11-20200531"
  description = "check https://docs.aws.amazon.com/eks/latest/userguide/eks-linux-ami-versions.html"
}

variable "ssh_port" {
  type        = string
  default     = "22"
  description = "EKS nodegroup ssh port"
}

variable "allowed_iplist" {
  type        = list
  default     = ["163.47.223.200/32", "111.69.188.8/32"]
  description = "Nat gateways or home IP's"
}

variable "desired_size" {
  type        = number
  default     = 3
  description = "EKS nodegroup desired size"
}

variable "min_size" {
  type        = number
  default     = 1
  description = "EKS nodegroup min size"
}

variable "max_size" {
  type        = number
  default     = 6
  description = "EKS nodegroup max size"
}