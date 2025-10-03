output "external_secrets_role_arn" {
  description = "IAM role ARN for External Secrets Operator"
  value       = module.external_secrets.role_arn
}

output "db_instance_endpoint" {
  description = "IAM role ARN for External Secrets Operator"
  value       = module.rds.db_instance_endpoint
}