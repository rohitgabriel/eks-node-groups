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
  type        = string
  default     = "1.16"
  description = "EKS version"
}

variable "nodegroup_ami_version" {
  type        = string
  default     = "1.16.8-20200507"
  description = "check https://docs.aws.amazon.com/eks/latest/userguide/eks-linux-ami-versions.html"
}
