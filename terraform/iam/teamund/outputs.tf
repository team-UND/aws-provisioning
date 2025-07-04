output "aws_iam_instance_profile_ec2_name" {
  value = aws_iam_instance_profile.ec2.name
}

output "aws_iam_instance_profile_prometheus_name" {
  value = aws_iam_instance_profile.prometheus.name
}

output "aws_iam_role_codedeploy_arn" {
  value = aws_iam_role.codedeploy.arn
}

output "aws_iam_role_lambda_execution_arn" {
  value = aws_iam_role.lambda_execution.arn
}
