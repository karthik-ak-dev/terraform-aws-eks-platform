# Terraform AWS EKS Platform

Production-ready EKS platform with Terraform modules, Helm charts, and GitHub Actions CI/CD.

## Overview

This repository provides everything needed to deploy and operate a complete Kubernetes platform on AWS:

- **Infrastructure as Code**: Terraform modules for VPC, EKS, ALB Controller, ECR, and CI/CD
- **Application Deployment**: Helm charts with IRSA, autoscaling, and ALB ingress support
- **CI/CD Pipelines**: GitHub Actions workflows for building and deploying services

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AWS EKS Platform                                    │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                              VPC                                      │  │
│  │  ┌─────────────────────────┐    ┌─────────────────────────┐           │  │
│  │  │     Public Subnets      │    │    Private Subnets      │           │  │
│  │  │  ┌───────────────────┐  │    │  ┌───────────────────┐  │           │  │
│  │  │  │  ALB (Ingress)    │  │    │  │   EKS Node Group  │  │           │  │
│  │  │  └───────────────────┘  │    │  │   ┌───────────┐   │  │           │  │
│  │  │  ┌───────────────────┐  │    │  │   │ Pod (IRSA)│   │  │           │  │
│  │  │  │   NAT Gateway     │──┼────┼──│   └───────────┘   │  │           │  │
│  │  │  └───────────────────┘  │    │  └───────────────────┘  │           │  │
│  │  └─────────────────────────┘    └─────────────────────────┘           │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
│  ┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐  │
│  │    EKS Cluster      │  │        ECR          │  │     CI/CD IAM       │  │
│  │  • Managed Nodes    │  │  • Image Storage    │  │  • GitHub OIDC      │  │
│  │  • Fargate (opt)    │  │  • Vulnerability    │  │  • Deploy Role      │  │
│  │  • OIDC Provider    │  │    Scanning         │  │  • ECR Push         │  │
│  └─────────────────────┘  └─────────────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Repository Structure

```
.
├── terraform/
│   └── modules/
│       ├── vpc/              # VPC with public/private subnets
│       ├── eks/              # EKS cluster, node groups, IRSA
│       ├── alb-controller/   # AWS Load Balancer Controller
│       ├── ecr/              # Container registry
│       └── ci-cd/            # GitHub Actions IAM
├── helm/
│   ├── charts/
│   │   └── microservice/     # Generic microservice chart
│   └── values/
│       ├── dev/              # Dev environment values
│       ├── stage/            # Stage environment values
│       └── prod/             # Production values
├── .github/
│   └── workflows/
│       ├── build-push.yml    # Build and push to ECR
│       └── deploy.yml        # Deploy to EKS
└── examples/
    └── complete/             # Full platform example
```

## Terraform Modules

| Module | Description |
|--------|-------------|
| [vpc](./terraform/modules/vpc) | VPC with multi-AZ subnets, NAT Gateway, flow logs |
| [eks](./terraform/modules/eks) | EKS cluster, node groups, Fargate, OIDC, IRSA roles |
| [alb-controller](./terraform/modules/alb-controller) | AWS Load Balancer Controller via Helm |
| [ecr](./terraform/modules/ecr) | ECR repositories with lifecycle policies |
| [ci-cd](./terraform/modules/ci-cd) | GitHub OIDC provider and IAM roles |

## Quick Start

### 1. Deploy Infrastructure

```bash
cd examples/complete
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

terraform init
terraform plan
terraform apply
```

### 2. Configure kubectl

```bash
aws eks update-kubeconfig --region us-east-1 --name myproject-eks-cluster
```

### 3. Deploy a Service

```bash
# Create namespace
kubectl create namespace myservice-dev

# Deploy with Helm
helm upgrade --install myservice-dev ./helm/charts/microservice \
  -f ./helm/values/dev/example-service.yaml \
  -n myservice-dev
```

## Features

### IAM Roles for Service Accounts (IRSA)

Pods can assume IAM roles without needing access keys:

```hcl
# In terraform.tfvars
application_roles = {
  myservice = {
    namespace       = "myservice-dev"
    service_account = "myservice-dev"
    policy_arns = [
      "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
    ]
  }
}
```

```yaml
# In Helm values
serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/myproject-myservice-role
```

### Horizontal Pod Autoscaling

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

### ALB Ingress

```yaml
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/healthcheck-path: /health
```

### GitHub Actions CI/CD

The repository includes workflow templates for CI/CD:

1. **Build and Push** (`build-push.yml`): Builds Docker images and pushes to ECR
2. **Deploy** (`deploy.yml`): Deploys services to EKS using Helm

#### Setting Up CI for Your Application

The `build-push.yml` workflow must be copied to each application repository that needs CI/CD:

```
your-app-repo/
├── .github/
│   └── workflows/
│       └── build-push.yml  <-- Copy from this repo
├── Dockerfile
└── src/
```

**Steps:**
1. Copy `.github/workflows/build-push.yml` to your application repository
2. Ensure your app repo is listed in `github_repositories` in Terraform (for OIDC)
3. Configure GitHub secrets in your app repo:

| Secret | Description |
|--------|-------------|
| `AWS_ROLE_ARN` | IAM role ARN for GitHub Actions (if using OIDC) |
| `AWS_ACCESS_KEY_ID` | Access key (if using IAM user) |
| `AWS_SECRET_ACCESS_KEY` | Secret key (if using IAM user) |

4. Set GitHub variable `USE_OIDC=true` to use OIDC authentication (recommended)

#### Example: Triggering a Build

```bash
# Via GitHub UI: Actions > Build and Push > Run workflow
# Or via GitHub CLI:
gh workflow run build-push.yml \
  -f service=myservice \
  -f region=us-east-1 \
  -f ecr_repository=myproject/services
```

## Node Groups

### On-Demand Nodes

```hcl
node_groups = {
  general = {
    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND"
    disk_size      = 50
    desired_size   = 2
    min_size       = 1
    max_size       = 4
  }
}
```

### Spot Instances

```hcl
node_groups = {
  spot = {
    instance_types = ["t3.medium", "t3.large"]
    capacity_type  = "SPOT"
    disk_size      = 50
    desired_size   = 2
    min_size       = 0
    max_size       = 10
    taints = [
      {
        key    = "spot"
        value  = "true"
        effect = "NO_SCHEDULE"
      }
    ]
  }
}
```

### Fargate Profiles

```hcl
fargate_profiles = {
  serverless = {
    selectors = [
      {
        namespace = "serverless"
        labels = {
          "compute-type" = "fargate"
        }
      }
    ]
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |
| helm | ~> 2.0 |
| tls | ~> 4.0 |

## Cost Optimization

| Environment | Recommendation |
|-------------|----------------|
| Dev | Single NAT Gateway, Spot instances, smaller node types |
| Stage | Single NAT Gateway, mixed On-Demand/Spot |
| Prod | Multi-AZ NAT, On-Demand for critical, Spot for batch |

## License

MIT License - see [LICENSE](LICENSE) for details.

## Author

**Karthik**

*AWS Platform Engineer specializing in Kubernetes, infrastructure automation, and cloud-native solutions.*
