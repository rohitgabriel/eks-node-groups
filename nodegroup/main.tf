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
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }
  remote_access {
      ec2_ssh_key = aws_key_pair.keypair.key_name
      source_security_group_ids = var.source_security_group_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_key_pair.keypair
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

#####
# SSH keypair
#####
resource "aws_key_pair" "keypair" {
  key_name   = "${var.app_name}-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCPp5QTuE2+K+ds9QHAa41b6qxz66tCthfC+xhN123BUfyIcKvMZrFgMwS4XoRMkMxr/M4ocx+QiFvu8mS9euLu3hvAHyqv8htFDF1minj+sq47nJZNFGxzMvtZEGrjTd88DiDlYnjqZT+M2TsBRuuCKqq3C/+72bY1+ez36ulBfmLfGrgS/4CPWCg04/SDpgYmcHkZcIusvJzdAiPNfOfSuDN64gRgNKhx0KTnHcS214ZKoQ8AcvyWZAwd8LjxCOuE+ec7grInTKaM0nj5ah9GRlMqh4opPis/YG4QiQmkUqmrs+VG8EG9pSBe5t2u4uctwxBMYomEacIBy9OLHMvx postgrestest"
}
