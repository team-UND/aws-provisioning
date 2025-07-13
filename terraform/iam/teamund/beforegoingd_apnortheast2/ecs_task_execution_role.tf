resource "aws_iam_role" "ecs_task_execution" {
  name = "ecs-task-execution-${data.terraform_remote_state.vpc.outputs.shard_id}"

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
  name        = "ecs-task-execution-secrets-manager-read-${data.terraform_remote_state.vpc.outputs.shard_id}"
  description = "Policy for EC2 to read secrets from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "secretsmanager:GetSecretValue"
        # Grant access only to the specific secrets required by the Spring Boot application
        Resource = [
          "arn:aws:secretsmanager:${data.terraform_remote_state.vpc.outputs.aws_region}:${data.aws_caller_identity.current.account_id}:secret:SpringBoot-Secrets-*",
          data.terraform_remote_state.mysql.outputs.aws_db_master_user_secret_arn
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
