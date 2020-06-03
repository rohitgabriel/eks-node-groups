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

  app_name           = var.app_name
  eks_version        = var.eks_version
  private_subnet_ids = module.vpc.private_subnets
  id                 = module.vpc.id
}

module "nodegroup" {
  source = "./nodegroup"

  app_name              = var.app_name
  instance_type         = var.instance_type
  private_subnet_ids    = module.vpc.private_subnets
  id                    = module.vpc.id
  cluster_name          = module.cluster.cluster_id
  ebs_volume_size       = var.ebs_volume_size
  nodegroup_ami_version = var.nodegroup_ami_version
}