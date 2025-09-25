data "aws_secretsmanager_secret_version" "db_username" {
  provider  = aws.vpc_region
  secret_id = data.aws_secretsmanager_secret.server.id
}

resource "aws_iam_role" "ecs_task" {
  description = "Role for ECS tasks"
  name        = "ecs-task-${data.terraform_remote_state.vpc.outputs.vpc_name}"

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

resource "aws_iam_policy" "ecs_task_exec" {
  description = "Allow ECS Exec functionality"
  name        = "ecs-task-exec-${data.terraform_remote_state.vpc.outputs.vpc_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_task_rds" {
  description = "Policy for ECS task to access RDS"
  name        = "ecs-task-rds-${data.terraform_remote_state.vpc.outputs.vpc_name}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "rds-db:connect"
      ],
      "Resource" : [
        "arn:aws:rds-db:${data.terraform_remote_state.vpc.outputs.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${data.terraform_remote_state.mysql.outputs.aws_db_instance_resource_id}/${jsondecode(data.aws_secretsmanager_secret_version.db_username.secret_string)["SPRING_DATASOURCE_USERNAME"]}"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task_exec.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_rds" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task_rds.arn
}
