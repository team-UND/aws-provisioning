output "aws_security_group_id" {
  description = "The ID of the security group for the internal LB"
  value       = aws_security_group.default.id
}

output "aws_lb_arn" {
  description = "The ARN of the internal Load Balancer"
  value       = aws_lb.default.arn
}

output "aws_lb_dns_name" {
  description = "The DNS name of the internal LB"
  value       = aws_lb.default.dns_name
}

output "aws_lb_zone_id" {
  description = "The canonical hosted zone ID of the internal LB"
  value       = aws_lb.default.zone_id
}

output "aws_lb_listener_http_arn" {
  description = "The ARN of the internal LB's HTTP listener"
  value       = aws_lb_listener.http.arn
}
