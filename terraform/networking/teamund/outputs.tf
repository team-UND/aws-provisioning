output "aws_security_group_lb_id" {
  description = "The ID of the security group for the external LB"
  value       = module.lb.aws_security_group_lb_id
}

output "aws_lb_arn" {
  description = "The ARN of the external Application Load Balancer"
  value       = module.lb.aws_lb_arn
}

output "aws_lb_listener_https_arn" {
  description = "The ARN of the external ALB's HTTPS listener"
  value       = module.lb.aws_lb_listener_https_arn
}

output "aws_lb_dns_name" {
  description = "The DNS name of the external LB"
  value       = module.lb.aws_lb_dns_name
}

output "aws_lb_zone_id" {
  description = "The canonical hosted zone ID of the external LB"
  value       = module.lb.aws_lb_zone_id
}
