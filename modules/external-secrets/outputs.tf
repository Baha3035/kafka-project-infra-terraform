# modules/external-secrets/outputs.tf
output "role_arn" {
  description = "ARN of the IAM role for External Secrets"
  value       = aws_iam_role.external_secrets.arn
}

output "policy_arn" {
  description = "ARN of the IAM policy for External Secrets"
  value       = aws_iam_policy.external_secrets.arn
}