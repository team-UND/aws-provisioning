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

  tags = {
    Name = "github-oidc-${data.terraform_remote_state.vpc.outputs.vpc_name}"
  }
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
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = flatten([
              for repo in local.repo_names :
              "repo:${local.org_name}/${repo}:ref:refs/heads/develop"
            ])
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions" {
  description = "Policy for GitHub Actions OIDC role to deploy to ECR and App Runner"
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
          data.terraform_remote_state.repository.outputs.aws_ecr_repository_server_build_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "apprunner:StartDeployment",
          "apprunner:DescribeService"
        ]
        Resource = "arn:aws:apprunner:${data.terraform_remote_state.vpc.outputs.aws_region}:${data.aws_caller_identity.current.account_id}:service/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_oidc.name
  policy_arn = aws_iam_policy.github_actions.arn
}
