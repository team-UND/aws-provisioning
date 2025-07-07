### ECS Task Execution Role ###
# 이 역할은 ECS Task가 ECR에서 컨테이너 이미지를 가져오고 CloudWatch에 로그를 쓰기 위해 사용합니다.
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

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role = aws_iam_role.ecs_task_execution.name
  # AWS 관리형 정책으로, ECR pull 및 CloudWatch logs 전송 권한을 포함합니다.
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
