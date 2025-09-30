variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "kafka-eks-project"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "eks_cluster_version" {
  description = "EKS cluster Kubernetes version"
  type        = string
  default     = "1.32"
}

variable "rds_postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "17.4"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "postgres"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "postgres"
}

variable "enable_cross_region_replication" {
  description = "Enable cross-region Kafka replication"
  type        = bool
  default     = false
}

variable "secondary_region" {
  description = "Secondary AWS region for cross-region replication"
  type        = string
  default     = "us-west-2"
}