data "aws_secretsmanager_secret" "server" {
  provider = aws.vpc_region
  name     = "stg/server/springboot"
}

data "aws_secretsmanager_secret" "prometheus" {
  provider = aws.vpc_region
  name     = "stg/prometheus"
}

resource "aws_iam_role" "ecs_task_execution" {
  description = "Role for ECS task execution"
  name        = "ecs-task-execution-${data.terraform_remote_state.vpc.outputs.vpc_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "ecs_task_execution_secrets_manager_read" {
  description = "Policy for EC2 to read secrets from Secrets Manager"
  name        = "ecs-task-execution-secrets-manager-read-${data.terraform_remote_state.vpc.outputs.vpc_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "secretsmanager:GetSecretValue"
        Resource = [
          # Add secret ARNs here
          data.aws_secretsmanager_secret.server.arn,
          data.aws_secretsmanager_secret.prometheus.arn
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_secrets_manager_read" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_task_execution_secrets_manager_read.arn
}
