locals {
  org_name    = "team-UND"
  repo_names  = ["beforegoing-server", "observability"]
  branch_name = "stg"
}

resource "aws_iam_role" "github_oidc" {
  description = "Role for GitHub Actions OIDC"
  name        = "github-oidc-${data.terraform_remote_state.vpc.outputs.vpc_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = data.terraform_remote_state.iam.outputs.aws_iam_openid_connect_provider_github_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = flatten([
              for repo in local.repo_names :
              "repo:${local.org_name}/${repo}:ref:refs/heads/${local.branch_name}"
            ])
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions" {
  description = "Policy for GitHub Actions OIDC role"
  name        = "github-actions-${data.terraform_remote_state.vpc.outputs.vpc_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages"
        ]
        Resource = [
          # ECR repositories for server and observability
          data.terraform_remote_state.repository.outputs.aws_ecr_repository_server_build_arn,
          data.terraform_remote_state.repository.outputs.aws_ecr_repository_prometheus_build_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          aws_iam_role.ecs_task_execution.arn,
          aws_iam_role.ecs_task.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_oidc.name
  policy_arn = aws_iam_policy.github_actions.arn
}
