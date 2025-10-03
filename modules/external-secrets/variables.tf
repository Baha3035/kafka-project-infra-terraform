# modules/external-secrets/variables.tf
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for External Secrets"
  type        = string
  default     = "kafka"
}

variable "secrets_arns" {
  description = "List of Secrets Manager ARNs to allow access to"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}