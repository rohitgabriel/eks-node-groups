resource "aws_eks_node_group" "node_group" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.app_name}-nodegroup"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.instance_type
  ami_type        = "AL2_x86_64"
  disk_size       = var.ebs_volume_size
  release_version = var.nodegroup_ami_version
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = {
      Name = "${var.app_name}-managed-by-terraform",
      "kubernetes.io/cluster/${var.app_name}" = "owned"
      }
}

#####
# IAM Nodegroup
#####
data "aws_iam_policy_document" "eks_nodegroup_role" {

  version = "2012-10-17"

    statement {

        actions = [
            "sts:AssumeRole"
        ]

        principals {
            type = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }

    }
}

resource "aws_iam_role" "eks_nodegroup_role" {
  name = format("%s-eks-nodegroup-role", var.app_name)
  assume_role_policy = data.aws_iam_policy_document.eks_nodegroup_role.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup_role.name
}