resource "aws_iam_role" "lambda" {
  description = "Role for Lambda functions"
  name        = "lambda-${data.terraform_remote_state.vpc.outputs.vpc_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "lambda-${data.terraform_remote_state.vpc.outputs.vpc_name}"
    Environment = data.terraform_remote_state.vpc.outputs.billing_tag
  }
}

resource "aws_iam_policy" "lambda_secrets_manager_read" {
  description = "Policy for EC2 to read secrets from Secrets Manager"
  name        = "lambda-secrets-manager-read-${data.terraform_remote_state.vpc.outputs.vpc_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "secretsmanager:GetSecretValue"
        Resource = [
          # Add secret ARNs here
          "arn:aws:secretsmanager:${data.terraform_remote_state.vpc.outputs.aws_region}:${data.aws_caller_identity.current.account_id}:secret:prod/sentry/lambda-*"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_secrets_manager_read" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_secrets_manager_read.arn
}
