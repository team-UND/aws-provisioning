data "aws_secretsmanager_secret" "server" {
  provider = aws.vpc_region
  name     = "dev/server/springboot"
}

data "aws_secretsmanager_secret" "prometheus" {
  provider = aws.vpc_region
  name     = "dev/prometheus"
}

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
  description = "Role for App Runner instance to access RDS and secrets"
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

resource "aws_iam_policy" "ar_rds" {
  description = "Policy for App Runner instance to access RDS"
  name        = "ar-rds-${data.terraform_remote_state.vpc.outputs.vpc_name}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "rds-db:connect"
      ],
      "Resource" : [
        "${data.terraform_remote_state.mysql.outputs.aws_db_instance_arn}/${data.terraform_remote_state.mysql.outputs.aws_db_instance_username}"
      ]
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
        data.aws_secretsmanager_secret.server.arn,
        data.aws_secretsmanager_secret.prometheus.arn,
        data.terraform_remote_state.mysql.outputs.aws_db_master_user_secret_arn
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ar_rds" {
  role       = aws_iam_role.ar_instance.name
  policy_arn = aws_iam_policy.ar_rds.arn
}

resource "aws_iam_role_policy_attachment" "ar_secrets_read" {
  role       = aws_iam_role.ar_instance.name
  policy_arn = aws_iam_policy.ar_secrets_read.arn
}
