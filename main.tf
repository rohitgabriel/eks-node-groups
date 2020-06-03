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