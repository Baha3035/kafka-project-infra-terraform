terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# Local values
locals {
  cluster_name = "${var.project_name}-${var.environment}"
  
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ClusterName = local.cluster_name
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  name            = local.cluster_name
  cidr            = local.vpc_cidr
  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
  
  enable_nat_gateway = true
  enable_vpn_gateway = false
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = local.common_tags
}

# EKS Module
module "eks" {
  source = "./modules/eks"
  
  cluster_name    = local.cluster_name
  cluster_version = var.eks_cluster_version
  
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  
  # Node groups configuration
  node_groups = {
    kafka_nodes = {
      name           = "kafka-nodes"
      instance_types = ["c5.large"]
      min_size       = 3
      max_size       = 6
      desired_size   = 3
      
      labels = {
        workload = "kafka"
      }
      
      taints = {
        kafka = {
          key    = "kafka"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }
    }
    
    general_nodes = {
      name           = "general-nodes"
      instance_types = ["t3.medium"]
      min_size       = 2
      max_size       = 4
      desired_size   = 2
    }
  }
  
  tags = local.common_tags
}

# External Secrets Module
module "external_secrets" {
  source = "./modules/external-secrets"
  
  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  namespace         = "kafka"
  
  secrets_arns = [
    module.rds.db_password_secret_arn,
    # Add other secret ARNs here if needed
  ]
  
  tags = local.common_tags
  
  depends_on = [module.eks]
}

# RDS Module
module "rds" {
  source = "./modules/rds"
  
  identifier     = "${local.cluster_name}-db"
  engine_version = var.rds_postgres_version
  instance_class = var.rds_instance_class
  
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true
  
  db_name  = var.db_name
  username = var.db_username
  
  vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.private_subnets
  allowed_cidr_blocks  = [local.vpc_cidr]
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  tags = local.common_tags
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"
  
  repositories = [
    "kafka-producer",
    "kafka-consumer-api", 
    "kafka-dashboard"
  ]
  
  tags = local.common_tags
}

# EBS CSI Driver Module (required for PVC/PV support)
module "ebs_csi_driver" {
  source = "./modules/ebs-csi-driver"
  
  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  
  tags = local.common_tags
  
  depends_on = [module.eks]
}