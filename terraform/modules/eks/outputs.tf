# ============================================================================
# EKS MODULE OUTPUTS
# ============================================================================

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS cluster API server"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.cluster.id
}

output "cluster_iam_role_arn" {
  description = "ARN of the IAM role used by the EKS cluster"
  value       = aws_iam_role.cluster.arn
}

output "cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  value       = aws_eks_cluster.main.version
}

# ============================================================================
# OIDC OUTPUTS
# ============================================================================

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "URL of the OIDC provider"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# ============================================================================
# NODE GROUP OUTPUTS
# ============================================================================

output "node_group_role_arn" {
  description = "ARN of the IAM role used by node groups"
  value       = aws_iam_role.node_group.arn
}

output "node_groups" {
  description = "Map of node group names to their ARNs"
  value = {
    for k, v in aws_eks_node_group.main : k => {
      arn    = v.arn
      status = v.status
    }
  }
}

# ============================================================================
# FARGATE OUTPUTS
# ============================================================================

output "fargate_role_arn" {
  description = "ARN of the Fargate execution role"
  value       = length(var.fargate_profiles) > 0 ? aws_iam_role.fargate[0].arn : null
}

output "fargate_profiles" {
  description = "Map of Fargate profile names to their ARNs"
  value = {
    for k, v in aws_eks_fargate_profile.main : k => {
      arn    = v.arn
      status = v.status
    }
  }
}

# ============================================================================
# ALB CONTROLLER OUTPUTS
# ============================================================================

output "alb_controller_role_arn" {
  description = "ARN of the IAM role for AWS Load Balancer Controller"
  value       = aws_iam_role.alb_controller.arn
}

# ============================================================================
# APPLICATION ROLE OUTPUTS
# ============================================================================

output "application_role_arns" {
  description = "Map of application role names to their ARNs"
  value = {
    for k, v in aws_iam_role.application : k => v.arn
  }
}
