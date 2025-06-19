output "aws_kms_key_prod_apne2_deployment_common_arn" {
  description = "Key for deployment"
  value       = aws_kms_key.deployment_common.arn
}
