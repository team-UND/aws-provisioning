resource "aws_iam_role" "lambda" {
  name = "lambda-${data.terraform_remote_state.vpc.outputs.shard_id}"

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
  name        = "lambda-secrets-manager-read-${data.terraform_remote_state.vpc.outputs.shard_id}"
  description = "Policy for EC2 to read secrets from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "secretsmanager:GetSecretValue"
        # Grant access only to secrets starting with "Lambda-Secrets-"
        Resource = "arn:aws:secretsmanager:${data.terraform_remote_state.vpc.outputs.aws_region}:${data.aws_caller_identity.current.account_id}:secret:Lambda-Secrets-*"
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

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
