# ============================================================================
# ECR MODULE OUTPUTS
# ============================================================================

output "repository_urls" {
  description = "Map of repository names to their URLs"
  value = {
    for name in var.repository_names :
    name => aws_ecr_repository.this[name].repository_url
  }
}

output "repository_arns" {
  description = "Map of repository names to their ARNs"
  value = {
    for name in var.repository_names :
    name => aws_ecr_repository.this[name].arn
  }
}

output "repository_registry_ids" {
  description = "Map of repository names to their registry IDs"
  value = {
    for name in var.repository_names :
    name => aws_ecr_repository.this[name].registry_id
  }
}
