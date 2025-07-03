resource "aws_iam_role" "prometheus" {
  name = "prometheus-${data.terraform_remote_state.vpc.outputs.shard_id}"

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
    Name        = "prometheus-${data.terraform_remote_state.vpc.outputs.shard_id}"
    Environment = data.terraform_remote_state.vpc.outputs.shard_id
  }
}

resource "aws_iam_instance_profile" "prometheus" {
  name = "prometheus-${data.terraform_remote_state.vpc.outputs.shard_id}"
  role = aws_iam_role.prometheus.name
}

resource "aws_iam_policy" "ec2_info_read" {
  name        = "ec2-info-read-${data.terraform_remote_state.vpc.outputs.shard_id}"
  description = "Policy for Prometheus to read information of EC2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "prometheus_ec2_info_read" {
  role       = aws_iam_role.prometheus.name
  policy_arn = aws_iam_policy.ec2_info_read.arn
}

resource "aws_iam_role_policy_attachment" "prometheus_ecr_access" {
  role       = aws_iam_role.prometheus.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "prometheus_s3_access" {
  role       = aws_iam_role.prometheus.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
