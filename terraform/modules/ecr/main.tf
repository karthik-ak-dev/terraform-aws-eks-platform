# ============================================================================
# ECR MODULE
# ============================================================================
# Creates ECR repositories with lifecycle policies for container image storage.

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ============================================================================
# ECR REPOSITORIES
# ============================================================================

resource "aws_ecr_repository" "this" {
  for_each = toset(var.repository_names)

  name                 = "${var.project_name}/${each.key}"
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.kms_key_arn != null ? "KMS" : "AES256"
    kms_key         = var.kms_key_arn
  }

  tags = var.tags
}

# ============================================================================
# LIFECYCLE POLICIES
# ============================================================================

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = toset(var.repository_names)

  repository = aws_ecr_repository.this[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${var.max_image_count} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.max_image_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ============================================================================
# REPOSITORY POLICIES (OPTIONAL)
# ============================================================================

resource "aws_ecr_repository_policy" "this" {
  for_each = var.create_repository_policy ? toset(var.repository_names) : toset([])

  repository = aws_ecr_repository.this[each.key].name
  policy     = var.repository_policy
}
