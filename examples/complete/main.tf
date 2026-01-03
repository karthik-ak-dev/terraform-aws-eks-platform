# ============================================================================
# COMPLETE EKS PLATFORM EXAMPLE
# ============================================================================
# This example demonstrates deploying a complete EKS platform including:
# - VPC with public and private subnets
# - EKS cluster with managed node groups
# - AWS Load Balancer Controller
# - ECR repositories
# - CI/CD IAM resources for GitHub Actions

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # Uncomment to use S3 backend
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "eks-platform/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.region
}

# Configure Helm provider after EKS cluster is created
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

# ============================================================================
# VPC
# ============================================================================

module "vpc" {
  source = "../../terraform/modules/vpc"

  name               = var.project_name
  vpc_cidr           = var.vpc_cidr
  az_count           = var.az_count
  cluster_name       = "${var.project_name}-eks-cluster"
  enable_nat_gateway = true
  single_nat_gateway = var.environment != "prod"
  enable_flow_logs   = var.environment == "prod"

  tags = var.tags
}

# ============================================================================
# EKS CLUSTER
# ============================================================================

module "eks" {
  source = "../../terraform/modules/eks"

  name       = var.project_name
  vpc_id     = module.vpc.vpc_id
  vpc_cidr   = module.vpc.vpc_cidr
  subnet_ids = module.vpc.private_subnet_ids

  kubernetes_version = var.kubernetes_version

  node_groups = var.node_groups

  fargate_profiles = var.fargate_profiles

  application_roles = var.application_roles

  tags = var.tags
}

# ============================================================================
# AWS LOAD BALANCER CONTROLLER
# ============================================================================

module "alb_controller" {
  source = "../../terraform/modules/alb-controller"

  cluster_name                  = module.eks.cluster_name
  vpc_id                        = module.vpc.vpc_id
  region                        = var.region
  iam_role_arn                  = module.eks.alb_controller_role_arn
  eks_cluster_security_group_id = module.eks.cluster_security_group_id
  enable_https                  = true

  depends_on = [module.eks]
}

# ============================================================================
# ECR REPOSITORIES
# ============================================================================

module "ecr" {
  source = "../../terraform/modules/ecr"

  project_name     = var.project_name
  repository_names = var.ecr_repositories
  scan_on_push     = true
  max_image_count  = 500

  tags = var.tags
}

# ============================================================================
# CI/CD
# ============================================================================

module "cicd" {
  source = "../../terraform/modules/ci-cd"

  project_name     = var.project_name
  repository_names = var.ecr_repositories

  # Use GitHub OIDC (recommended)
  create_github_oidc_provider = true
  create_github_actions_role  = true
  github_repositories         = var.github_repositories

  # Or use IAM users (legacy)
  create_ci_user     = false
  create_cd_user     = false
  create_access_keys = false

  tags = var.tags
}
