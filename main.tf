provider "aws" {
  version = ">= 2.64"
  region  = var.AWS_REGION
}

terraform {
  required_version = ">= 0.12"

  backend "remote" {
    organization = "testapp"

    workspaces {
      name = "dev"
    }
  }
}

module "vpc" {
  source = "./vpc"

  vpc_cidr  = var.vpc_cidr
  app_name  = var.app_name
  app_name2 = var.app_name2

}

module "cluster" {
  source = "./cluster"

  app_name              = var.app_name
  eks_version           = var.eks_version
  private_subnet_ids    = module.vpc.private_subnets
  id                    = module.vpc.id
  public_ip_nat_gateway = module.vpc.public_ip_nat_gateway
  allowed_iplist        = var.allowed_iplist
}

module "nodegroup" {
  source = "./nodegroup"

  app_name                  = var.app_name
  instance_type             = var.instance_type
  private_subnet_ids        = module.vpc.private_subnets
  id                        = module.vpc.id
  cluster_name              = module.cluster.cluster_id
  ebs_volume_size           = var.ebs_volume_size
  nodegroup_ami_version     = var.nodegroup_ami_version
  source_security_group_ids = [aws_security_group.public_subnets.id]
  desired_size              = var.desired_size
  min_size                  = var.min_size
  max_size                  = var.max_size
  efs_arn                   = module.efs.efs_arn
}

module efs {
  source = "./efs"

  app_name        = var.app_name
  region          = var.AWS_REGION
  vpc_id          = module.vpc.id
  subnets         = module.vpc.private_subnets
  security_groups = [aws_security_group.ingress_efs.id]
}

module "cluster2" {
  source = "./cluster"

  app_name              = var.app_name2
  eks_version           = var.eks_version
  private_subnet_ids    = module.vpc.private_subnets
  id                    = module.vpc.id
  public_ip_nat_gateway = module.vpc.public_ip_nat_gateway
  allowed_iplist        = var.allowed_iplist
}

module "nodegroup2" {
  source = "./nodegroup"

  app_name                  = var.app_name2
  instance_type             = var.instance_type
  private_subnet_ids        = module.vpc.private_subnets
  id                        = module.vpc.id
  cluster_name              = module.cluster2.cluster_id
  ebs_volume_size           = var.ebs_volume_size
  nodegroup_ami_version     = var.nodegroup_ami_version
  source_security_group_ids = [aws_security_group.public_subnets.id]
  desired_size              = var.desired_size
  min_size                  = var.min_size
  max_size                  = var.max_size
  efs_arn                   = module.efs.efs_arn
}

#####
# Security Groups
#####
resource "aws_security_group" "public_subnets" {

  vpc_id      = module.vpc.id
  name        = "${var.app_name}_ssh"
  description = "security group to allow inbound traffic on port ${var.ssh_port} from internet"
  # depends_on  = [aws_security_group.appserver]
  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_iplist
  }
  egress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = [module.vpc.cidr_block]
  }
  tags = {
    project = "${var.app_name}"
  }
}

// Create Security group to allow ingress traffic to EKS
resource "aws_security_group" "private_subnets" {

  vpc_id      = module.vpc.id
  name        = "${var.app_name}_ingress_ssh"
  description = "security group to allow inbound traffic on port ${var.ssh_port} from public subnets"
  ingress {
    from_port       = var.ssh_port
    to_port         = var.ssh_port
    protocol        = "tcp"
    security_groups = [aws_security_group.public_subnets.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    project = "${var.app_name}"
  }
}

resource "aws_security_group" "ingress_efs" {
  name   = "ingress_efs_sg"
  vpc_id = module.vpc.id

  ingress {
    cidr_blocks = [var.vpc_cidr]
    from_port   = var.efs_port
    to_port     = var.efs_port
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}