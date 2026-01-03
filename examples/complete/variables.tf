# ============================================================================
# VARIABLES FOR COMPLETE EXAMPLE
# ============================================================================

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment (dev, stage, prod)"
  type        = string
  default     = "dev"
}

# ============================================================================
# VPC
# ============================================================================

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones"
  type        = number
  default     = 2
}

# ============================================================================
# EKS
# ============================================================================

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "node_groups" {
  description = "EKS node group configurations"
  type = map(object({
    instance_types = list(string)
    capacity_type  = string
    disk_size      = number
    desired_size   = number
    min_size       = number
    max_size       = number
    labels         = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = optional(string)
      effect = string
    })), [])
  }))
  default = {
    general = {
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      disk_size      = 50
      desired_size   = 2
      min_size       = 1
      max_size       = 4
    }
  }
}

variable "fargate_profiles" {
  description = "Fargate profile configurations"
  type = map(object({
    selectors = list(object({
      namespace = string
      labels    = optional(map(string))
    }))
  }))
  default = {}
}

variable "application_roles" {
  description = "Application IAM roles for IRSA"
  type = map(object({
    namespace       = string
    service_account = string
    policy_arns     = list(string)
  }))
  default = {}
}

# ============================================================================
# ECR
# ============================================================================

variable "ecr_repositories" {
  description = "List of ECR repository names"
  type        = list(string)
  default     = ["services"]
}

# ============================================================================
# CI/CD
# ============================================================================

variable "github_repositories" {
  description = "GitHub repositories allowed to assume the CI/CD role (format: owner/repo)"
  type        = list(string)
  default     = []
}

# ============================================================================
# TAGS
# ============================================================================

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
  }
}
