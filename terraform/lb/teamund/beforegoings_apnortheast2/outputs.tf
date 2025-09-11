output "aws_security_group_id" {
  description = "The ID of the security group for the internal LB"
  value       = module.internal.aws_security_group_id
}

output "aws_lb_arn" {
  description = "The ARN of the internal Application Load Balancer"
  value       = module.internal.aws_lb_arn
}

output "aws_lb_dns_name" {
  description = "The DNS name of the internal LB"
  value       = module.internal.aws_lb_dns_name
}

output "aws_lb_zone_id" {
  description = "The canonical hosted zone ID of the internal LB"
  value       = module.internal.aws_lb_zone_id
}

output "aws_lb_listener_http_arn" {
  description = "The ARN of the internal ALB's HTTP listener"
  value       = module.internal.aws_lb_listener_http_arn
}
