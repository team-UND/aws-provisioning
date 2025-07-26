# Data Sources
data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

resource "aws_security_group" "ec2" {
  description = "EC2 SG for ${var.shard_id}"
  name        = "ec2-sg-${var.vpc_name}"
  vpc_id      = var.vpc_id

  tags = var.sg_variables.ec2.tags[var.shard_id]
}

resource "aws_vpc_security_group_egress_rule" "ec2" {
  description       = "Allow traffic from the ECS Task"
  security_group_id = aws_security_group.ec2.id
  ip_protocol       = "-1"
  cidr_ipv4         = var.ec2_egress_cidr
}

# ECS Cluster & Compute Capacity (EC2 ASG)
resource "aws_ecs_cluster" "default" {
  name = "ecs-cluster-${var.vpc_name}"
}

resource "aws_launch_template" "lt" {
  name_prefix   = "lt-${var.vpc_name}"
  image_id      = data.aws_ssm_parameter.ecs_optimized_ami.value
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Configure the ECS agent to use the correct cluster
    echo "ECS_CLUSTER=${aws_ecs_cluster.default.name}" > /etc/ecs/ecs.config

    # Create and enable a ${var.swap_file_size_gb}GB swap file if it doesn't exist
    if [ ! -f /swapfile ]; then
      fallocate -l ${var.swap_file_size_gb}G /swapfile
      chmod 600 /swapfile
      mkswap /swapfile
      swapon /swapfile
      echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

      # Tune swappiness to use swap only when absolutely necessary
      # A lower value (ex. 10) is generally recommended for performance-sensitive applications
      sysctl vm.swappiness=${var.swappiness_value}
      echo 'vm.swappiness=${var.swappiness_value}' | tee -a /etc/sysctl.conf
    fi
  EOF
  )

  vpc_security_group_ids = [aws_security_group.ec2.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "lt-${var.vpc_name}"
    }
  }
}

resource "aws_autoscaling_group" "default" {
  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  min_size            = var.ec2_min_size
  max_size            = var.ec2_max_size
  desired_capacity    = var.ec2_desired_capacity
  vpc_zone_identifier = var.private_subnet_ids

  tag {
    key                 = "Name"
    value               = "asg-${var.vpc_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Monitoring"
    value               = "enabled"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "default" {
  name = "cp-${var.vpc_name}"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.default.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "default" {
  cluster_name = aws_ecs_cluster.default.name

  capacity_providers = [aws_ecs_capacity_provider.default.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.default.name
  }
}
