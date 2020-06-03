
  resource "aws_eks_cluster" "eks_cluster" {

    name    = var.app_name
    version = var.eks_version
    role_arn = aws_iam_role.eks_cluster_role.arn

    vpc_config {
        endpoint_private_access = false
        endpoint_public_access  = true
        public_access_cidrs     = 0.0.0.0/0
        security_group_ids = [
            aws_security_group.cluster_master_sg.id
        ]
        subnet_ids = module.vpc.private_subnets
    }
    depends_on = [
    "aws_iam_role_policy_attachment.AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.AmazonEKSServicePolicy",
    "aws_cloudwatch_log_group.eks"
    ]

    enabled_cluster_log_types = ["api", "audit"]
    tags = {
        "kubernetes.io/cluster/${var.app_name}" = "shared"
    }

}

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.app_name}/cluster"
  retention_in_days = 7

}
#####
# IAM Cluster role
#####
data "aws_iam_policy_document" "eks_cluster_role" {

    version = "2012-10-17"

    statement {

        actions = [
            "sts:AssumeRole"
        ]

        principals {
            type = "Service"
            identifiers = ["eks.amazonaws.com"]
        }

    }

}

resource "aws_iam_role" "eks_cluster_role" {
  name = format("%s-eks-cluster-role", var.app_name)
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_role.json
}


resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
    role = aws_iam_role.eks_cluster_role.name
}

#####
# Security Groups for Control Plane
#####
resource "aws_security_group" "cluster_security_group" {

    name = format("%s-cluster_security_group", var.cluster_name)
    vpc_id = var.cluster_vpc.id

    egress {
        from_port   = 0
        to_port     = 0

        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    tags = {
        Name = format("%s-cluster_security_group", var.cluster_name)
    }

}

resource "aws_security_group_rule" "cluster_ingress_https" {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"

    security_group_id = aws_security_group.cluster_security_group.id
    type = "ingress"
}