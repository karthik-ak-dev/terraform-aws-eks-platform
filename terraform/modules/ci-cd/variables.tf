# ============================================================================
# CI/CD MODULE VARIABLES
# ============================================================================

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "repository_names" {
  description = "List of ECR repository names to access"
  type        = list(string)
  default     = ["services"]
}

# ============================================================================
# IAM USER OPTIONS
# ============================================================================

variable "create_ci_user" {
  description = "Whether to create IAM user for CI to push to ECR"
  type        = bool
  default     = false
}

variable "create_cd_user" {
  description = "Whether to create IAM user for CD to deploy to EKS"
  type        = bool
  default     = false
}

variable "create_access_keys" {
  description = "Whether to create access keys for the users (warning: keys will be stored in state)"
  type        = bool
  default     = false
}

# ============================================================================
# GITHUB OIDC OPTIONS (RECOMMENDED)
# ============================================================================

variable "create_github_oidc_provider" {
  description = "Whether to create GitHub OIDC provider (set to false if already exists)"
  type        = bool
  default     = true
}

variable "github_oidc_provider_arn" {
  description = "ARN of existing GitHub OIDC provider (required if create_github_oidc_provider is false)"
  type        = string
  default     = ""
}

variable "create_github_actions_role" {
  description = "Whether to create IAM role for GitHub Actions"
  type        = bool
  default     = true
}

variable "github_repositories" {
  description = "List of GitHub repositories allowed to assume the role (format: owner/repo)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
