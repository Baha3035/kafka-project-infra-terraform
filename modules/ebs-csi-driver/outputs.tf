output "ebs_csi_driver_role_arn" {
  description = "ARN of the IAM role for EBS CSI driver"
  value       = aws_iam_role.ebs_csi_driver.arn
}

output "ebs_csi_addon_id" {
  description = "ID of the EBS CSI driver addon"
  value       = aws_eks_addon.ebs_csi_driver.id
}

output "pod_identity_addon_id" {
  description = "ID of the Pod Identity agent addon"
  value       = aws_eks_addon.pod_identity_agent.id
}