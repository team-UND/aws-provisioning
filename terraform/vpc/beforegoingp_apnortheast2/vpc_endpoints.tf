# Security Group for VPC Endpoints
resource "aws_security_group" "vpc_endpoints" {
  description = "VPC Endpoints SG for ${var.shard_id}"
  name        = "vpc-endpoints-sg-${var.vpc_name}"
  vpc_id      = aws_vpc.default.id

  tags = {
    Name = "vpc-endpoints-sg-${var.vpc_name}"
  }
}

# Allow HTTPS from the entire VPC
resource "aws_vpc_security_group_ingress_rule" "vpc_https_vpc_endpoints" {
  description       = "Allow HTTPS traffic from the VPC to the VPC Endpoints"
  security_group_id = aws_security_group.vpc_endpoints.id
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = aws_vpc.default.cidr_block
}

locals {
  # A set of service names for which to create VPC endpoints.
  # This makes it easy to add or remove endpoints in the future.
  endpoint_services = toset([
    "ssm",
    "ssmmessages",
    "ec2messages",
    "secretsmanager",
    # For ECS Agent to communicate with the control plane
    "ecs-agent",
    "ecs-telemetry",
    "ecs",
    # For ECR to pull container images
    "ecr.api",
    "ecr.dkr",
    # For CloudWatch Logs and STS
    "logs",
    "sts",
    # For KMS to encrypt/decrypt secrets and other data
    "kms"
  ])
}

# Create VPC Interface Endpoints for various AWS services
resource "aws_vpc_endpoint" "interface_endpoints" {
  for_each            = var.create_interface_endpoints ? local.endpoint_services : toset([])
  vpc_id              = aws_vpc.default.id
  service_name        = "com.amazonaws.${var.aws_region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.vpc_endpoints.id]

  tags = {
    Name = "${each.key}-endpoint-${var.vpc_name}"
  }
}

# S3 Gateway Endpoint is required for ECR to pull image layers from S3 privately
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = aws_vpc.default.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  # Associate with all route tables (public and private) to ensure any resource
  # within the VPC can access S3 privately.
  route_table_ids = concat(
    [aws_route_table.public.id],
    aws_route_table.private[*].id,
    aws_route_table.private_db[*].id
  )

  tags = {
    Name = "s3-endpoint-${var.vpc_name}"
  }
}

resource "aws_vpc_endpoint" "dynamodb_gateway" {
  vpc_id            = aws_vpc.default.id
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  # Associate with all route tables (public and private) to ensure any resource
  # within the VPC can access DynamoDB privately.
  route_table_ids = concat(
    [aws_route_table.public.id],
    aws_route_table.private[*].id,
    aws_route_table.private_db[*].id
  )

  tags = {
    Name = "dynamodb-endpoint-${var.vpc_name}"
  }
}
