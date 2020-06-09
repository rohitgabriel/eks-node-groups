#####
# VPC
#####
resource "aws_vpc" "vpc_network_VPC" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    "Name" = "${var.vpc_cidr} - ${var.app_name}"
  }
}

#####
# Subnets
#####
locals {
  public_cidr_range = cidrsubnet(var.vpc_cidr, 2, 0)
  private_cidr_range = cidrsubnet(var.vpc_cidr, 2, 1)
  app_name = var.app_name
  app_name2 = var.app_name2
}

resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.vpc_network_VPC.id
  cidr_block              = cidrsubnet(local.public_cidr_range, 2, count.index)
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.AWS_REGION}${var.availability_zones[count.index]}"

  tags = {
    "Name" = "${var.app_name}_Public_${var.availability_zones[count.index]}",
    "kubernetes.io/role/elb" = 1,
    # "kubernetes.io/cluster/${var.app_name}" = "shared"
    # "kubernetes.io/cluster/${var.app_name2}" = "shared"
  }
}

resource "aws_subnet" "private" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.vpc_network_VPC.id
  cidr_block              = cidrsubnet(local.private_cidr_range, 2, count.index)
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.AWS_REGION}${var.availability_zones[count.index]}"

  tags = {
    "Name" = "${var.app_name}_Private_${var.availability_zones[count.index]}",
    "kubernetes.io/role/internal-elb" = 1,
    # "kubernetes.io/cluster/${var.app_name}" = "shared"
    # "kubernetes.io/cluster/${var.app_name2}" = "shared"
  }
}

//Internet gateway
resource "aws_internet_gateway" "vpc_network_internetgw" {
  vpc_id = aws_vpc.vpc_network_VPC.id

  tags = {
    Name = "${var.app_name}_igw"
  }
}

//NAT gateway
resource "aws_eip" "public" {
  count = length(var.availability_zones)

  vpc = true
  tags = {
    Name = "${var.app_name}_natgw_Public_${var.availability_zones[count.index]}"
  }
}

resource "aws_nat_gateway" "public" {
  count = length(var.availability_zones)

  allocation_id = aws_eip.public[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.app_name}_natgw_Public_${var.availability_zones[count.index]}"
  }

  depends_on = [
    aws_internet_gateway.vpc_network_internetgw
  ]
}

#####
# Route Tables
#####
resource "aws_route_table" "public" {

  vpc_id = aws_vpc.vpc_network_VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_network_internetgw.id
  }

  tags = {
    Name = "${var.app_name}_Public"
  }
}

resource "aws_route_table" "private" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.vpc_network_VPC.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public[count.index].id
  }

  tags = {
    Name = "${var.app_name}_Private_${var.availability_zones[count.index]}"
  }
}

#####
# Route Assocations
#####
resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

#####
# Subnet data
#####
data "aws_subnet_ids" "all" {
  vpc_id     = aws_vpc.vpc_network_VPC.id
  depends_on = [aws_subnet.private]
}

data "aws_subnet_ids" "privatesubnets" {
  vpc_id     = aws_vpc.vpc_network_VPC.id
  depends_on = [aws_subnet.private]
  filter {
    name   = "tag:Name"
    values = ["*Private*"]
  }
}

data "aws_subnet_ids" "publicsubnets" {
  vpc_id     = aws_vpc.vpc_network_VPC.id
  depends_on = [aws_subnet.public]
  filter {
    name   = "tag:Name"
    values = ["*Public*"]
  }
}