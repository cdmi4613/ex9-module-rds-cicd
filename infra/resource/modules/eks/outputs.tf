# ################################################################################
# EKS Cluster
# ################################################################################

output "cluster_name" {
  description = "EKS Cluster Name"
  value       = aws_eks_cluster.this.name
}


output "cluster_arn" {
  description = "EKS Cluster ARN"
  value       = aws_eks_cluster.this.arn
}


output "cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = aws_eks_cluster.this.endpoint
}


# ################################################################################
# EKS Security Group
# ################################################################################

output "cluster_security_group_id" {
  description = "EKS Cluster Security Group ID"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}


# ################################################################################
# Node Group
# ################################################################################

output "node_group_name" {
  description = "EKS Node Group Name"
  value       = aws_eks_node_group.this.node_group_name
}


# ################################################################################
# IAM Roles
# ################################################################################

output "cluster_role_arn" {
  description = "EKS Cluster IAM Role ARN"
  value       = aws_iam_role.eks_cluster.arn
}


output "node_role_arn" {
  description = "EKS Node Group IAM Role ARN"
  value       = aws_iam_role.eks_node.arn
}
