resource "aws_iam_role" "ar_service" {
  description = "Role for App Runner service to access ECR"
  name        = "ar-service-${data.terraform_remote_state.vpc.outputs.vpc_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "build.apprunner.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ar_ecr_access" {
  role       = aws_iam_role.ar_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

resource "aws_iam_role" "ar_instance" {
  description = "Role for App Runner instance to access secrets"
  name        = "ar-instance-${data.terraform_remote_state.vpc.outputs.vpc_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "tasks.apprunner.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "ar_secrets_read" {
  description = "Policy for App Runner instance to read secrets"
  name        = "ar-secrets-read-${data.terraform_remote_state.vpc.outputs.vpc_name}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = "secretsmanager:GetSecretValue",
      Resource = [
        # Add secret ARNs here
        "arn:aws:secretsmanager:${data.terraform_remote_state.vpc.outputs.aws_region}:${data.aws_caller_identity.current.account_id}:secret:dev/server/springboot-*",
        "arn:aws:secretsmanager:${data.terraform_remote_state.vpc.outputs.aws_region}:${data.aws_caller_identity.current.account_id}:secret:dev/prometheus-*",
        data.terraform_remote_state.mysql.outputs.aws_db_master_user_secret_arn
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ar_secrets_read" {
  role       = aws_iam_role.ar_instance.name
  policy_arn = aws_iam_policy.ar_secrets_read.arn
}
