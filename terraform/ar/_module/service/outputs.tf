output "aws_security_group_id" {
  description = "The ID of the App Runner security group"
  value       = aws_security_group.default.id
}

output "aws_apprunner_custom_domain_association_certificate_validation_records" {
  description = "Validation records for the App Runner custom domain"
  value       = aws_apprunner_custom_domain_association.default.certificate_validation_records
}

output "aws_apprunner_custom_domain_association_dns_target" {
  description = "DNS target for the App Runner custom domain"
  value       = aws_apprunner_custom_domain_association.default.dns_target
}
