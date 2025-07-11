locals {
  org_name   = "team-UND"
  repo_names = ["beforegoing-server", "observability"]
}

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

resource "aws_iam_role" "github_oidc" {
  name = "github-oidc-${data.terraform_remote_state.vpc.outputs.shard_id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = flatten([
              for repo in local.repo_names :
              "repo:${local.org_name}/${repo}:ref:refs/heads/main"
            ])
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions" {
  name        = "github-actions-${data.terraform_remote_state.vpc.outputs.shard_id}"
  description = "Policy for GitHub Actions OIDC role"

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
          data.terraform_remote_state.repository.outputs.aws_ecr_repository_beforegoingd_server_build_arn,
          data.terraform_remote_state.repository.outputs.aws_ecr_repository_beforegoingd_prometheus_build_arn
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
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = aws_iam_role.ecs_task_execution.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_oidc.name
  policy_arn = aws_iam_policy.github_actions.arn
}
