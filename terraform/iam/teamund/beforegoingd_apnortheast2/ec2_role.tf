resource "aws_iam_role" "ec2" {
  name = "ec2-${data.terraform_remote_state.vpc.outputs.shard_id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "ec2-${data.terraform_remote_state.vpc.outputs.shard_id}"
    Environment = data.terraform_remote_state.vpc.outputs.shard_id
  }
}

resource "aws_iam_instance_profile" "ec2" {
  name = "ec2-${data.terraform_remote_state.vpc.outputs.shard_id}"
  role = aws_iam_role.ec2.name
}

resource "aws_iam_policy" "secrets_manager_read" {
  name        = "secrets-manager-read-${data.terraform_remote_state.vpc.outputs.shard_id}"
  description = "Policy for EC2 to read secrets from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "secretsmanager:GetSecretValue"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_secrets_manager_read" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.secrets_manager_read.arn
}

resource "aws_iam_role_policy_attachment" "ec2_ecr_access" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "ec2_s3_access" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
