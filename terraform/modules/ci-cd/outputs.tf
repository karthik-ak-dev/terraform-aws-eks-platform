# ============================================================================
# CI/CD MODULE OUTPUTS
# ============================================================================

# CI User outputs
output "ci_user_name" {
  description = "Name of the IAM user for CI to push to ECR"
  value       = var.create_ci_user ? aws_iam_user.ci_user[0].name : null
}

output "ci_user_arn" {
  description = "ARN of the IAM user for CI to push to ECR"
  value       = var.create_ci_user ? aws_iam_user.ci_user[0].arn : null
}

output "ci_access_key_id" {
  description = "Access key ID for the CI user"
  value       = var.create_ci_user && var.create_access_keys ? aws_iam_access_key.ci_user_key[0].id : null
  sensitive   = true
}

output "ci_secret_access_key" {
  description = "Secret access key for the CI user (WARNING: sensitive value)"
  value       = var.create_ci_user && var.create_access_keys ? aws_iam_access_key.ci_user_key[0].secret : null
  sensitive   = true
}

# CD User outputs
output "cd_user_name" {
  description = "Name of the IAM user for CD to deploy to EKS"
  value       = var.create_cd_user ? aws_iam_user.cd_user[0].name : null
}

output "cd_user_arn" {
  description = "ARN of the IAM user for CD to deploy to EKS"
  value       = var.create_cd_user ? aws_iam_user.cd_user[0].arn : null
}

output "cd_access_key_id" {
  description = "Access key ID for the CD user"
  value       = var.create_cd_user && var.create_access_keys ? aws_iam_access_key.cd_user_key[0].id : null
  sensitive   = true
}

output "cd_secret_access_key" {
  description = "Secret access key for the CD user (WARNING: sensitive value)"
  value       = var.create_cd_user && var.create_access_keys ? aws_iam_access_key.cd_user_key[0].secret : null
  sensitive   = true
}

# GitHub OIDC outputs
output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = var.create_github_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : var.github_oidc_provider_arn
}

output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions"
  value       = var.create_github_actions_role ? aws_iam_role.github_actions[0].arn : null
}
