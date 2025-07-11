output "aws_security_group_lb_id" {
  description = "The ID of the security group for the external LB"
  value       = aws_security_group.default.id
}

output "aws_lb_arn" {
  description = "The ARN of the external Application Load Balancer"
  value       = aws_lb.default.arn
}

output "aws_lb_listener_https_arn" {
  description = "The ARN of the external ALB's HTTPS listener"
  value       = aws_lb_listener.https.arn
}

output "aws_lb_dns_name" {
  description = "The DNS name of the external LB"
  value       = aws_lb.default.dns_name
}

output "aws_lb_zone_id" {
  description = "The canonical hosted zone ID of the external LB"
  value       = aws_lb.default.zone_id
}
