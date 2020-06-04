provider "aws" {
  version = ">= 2.53"
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

  app_name = var.app_name
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
}

#####
# Security Groups
#####
resource "aws_security_group" "egress" {
  # vpc_id      = aws_vpc.vpc_network_VPC.id
  vpc_id      = module.vpc.id
  name        = "${var.app_name}_egress"
  description = "security group to allow all egress traffic"
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

// Create Security group to allow ingress traffic 

# resource "aws_security_group" "postgresdb" {

#   vpc_id      = aws_vpc.vpc_network_VPC.id
#   name        = "${var.app_name}_ingress_postgresdb"
#   description = "security group that allows traffic to database"
#   ingress {
#     from_port   = var.db_port
#     to_port     = var.db_port
#     protocol    = "tcp"
#     security_groups = [aws_security_group.appserver.id]
#   }
#   tags = {
#     project = "${var.app_name}"
#   }
# }