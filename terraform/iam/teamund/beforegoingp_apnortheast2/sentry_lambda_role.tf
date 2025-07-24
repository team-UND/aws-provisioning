resource "aws_iam_role" "sentry" {
  description = "Role for Sentry Lambda function"
  name        = "sentry-${data.terraform_remote_state.vpc.outputs.vpc_name}"

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
    Name        = "sentry-${data.terraform_remote_state.vpc.outputs.vpc_name}"
    Environment = data.terraform_remote_state.vpc.outputs.billing_tag
  }
}

resource "aws_iam_policy" "sentry_secrets_read" {
  description = "Policy for Sentry Lambda function to read secrets from Secrets Manager"
  name        = "sentry-secrets-read-${data.terraform_remote_state.vpc.outputs.vpc_name}"

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

resource "aws_iam_role_policy_attachment" "sentry_execution" {
  role       = aws_iam_role.sentry.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "sentry_secrets_read" {
  role       = aws_iam_role.sentry.name
  policy_arn = aws_iam_policy.sentry_secrets_read.arn
}
