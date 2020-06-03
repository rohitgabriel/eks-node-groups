output "endpoint" {
  value = "${aws_eks_cluster.eks_cluster.endpoint}"
}

output "certificate_authority" {
  value = "${aws_eks_cluster.eks_cluster.certificate_authority.0.data}"
}
output "cluster_id" {
  value = "${aws_eks_cluster.eks_cluster.id}"
}