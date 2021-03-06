#####
# Global 
#####
variable "AWS_REGION" {
  default     = "ap-southeast-2"
  description = "Set the AWS region"
  type        = string
}

#####
# EKS Cluster
#####
variable "app_name" {
  type        = string
  default     = "eks"
  description = "Name of the application"
}

variable "app_name2" {
  type        = string
  default     = "eks2"
  description = "Name of the application"
}

variable "eks_version" {
  type    = string
  default = "1.16"
  # default     = "1.15"
  description = "EKS version"
}

variable "allowed_iplist" {
  type        = list
  default     = ["163.47.223.96/32", "111.69.188.8/32", "202.180.77.121/32", "3.105.195.250/32", "0.0.0.0/0"]
  description = "Nat gateways or home IP's"
}
#####
# EKS Nodegroups
#####
variable "instance_type" {
  default     = ["t3.medium"]
  description = "Set the EC2 Instance type"
  type        = list
}

variable "ebs_volume_size" {
  default     = "60"
  description = "Set the EBS volume size in GB"
  type        = string
}

variable "nodegroup_ami_version" {
  type = string
  # default = "1.16.8-20200507"
  default = "1.16.8-20200609"
  # can't upgrade from 1.15 coz of a bug in aws provider https://github.com/terraform-providers/terraform-provider-aws/issues/12675
  # default     = "1.15.11-20200531"
  description = "check https://docs.aws.amazon.com/eks/latest/userguide/eks-linux-ami-versions.html"
}

variable "ssh_port" {
  type        = string
  default     = "22"
  description = "EKS nodegroup ssh port"
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

variable "autoscaler_version" {
  description = "Set the Autoscaler version"
  default     = "asia.gcr.io/k8s-artifacts-prod/autoscaling/cluster-autoscaler:v1.16.5"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account id"
  default     = "793916195974"
  type        = string
}

variable "aws_devops_user" {
  description = "AWS devops user"
  default     = "Administrator"
  type        = string
}
#####
# VPC
#####
variable vpc_cidr {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR range to assign to the VPC"
}

#####
# EFS
#####
variable "efs_port" {
  type        = string
  default     = "2049"
  description = "EKS nodegroup EFS port"
}

variable "efs_arn" {
  type        = string
  default     = ""
  description = "EFS ARN"
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources"
}