resource "aws_codedeploy_app" "prometheus" {
  name = "codedeploy-app-prometheus-${data.terraform_remote_state.vpc.outputs.shard_id}"

  tags = {
    Name        = "codedeploy-app-prometheus-${data.terraform_remote_state.vpc.outputs.shard_id}"
    Environment = data.terraform_remote_state.vpc.outputs.billing_tag
  }
}

resource "aws_codedeploy_deployment_group" "prometheus" {
  app_name              = aws_codedeploy_app.prometheus.name
  deployment_group_name = "codedeploy-group-prometheus-${data.terraform_remote_state.vpc.outputs.shard_id}"
  service_role_arn      = data.terraform_remote_state.iam.outputs.aws_iam_role_codedeploy_arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "aws:autoscaling:groupName"
      type  = "KEY_AND_VALUE"
      value = data.terraform_remote_state.prometheus.outputs.aws_autoscaling_group_name
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  load_balancer_info {
    target_group_info {
      name = data.terraform_remote_state.prometheus.outputs.aws_lb_target_group_external_name
    }
  }

  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM"]
  }

  trigger_configuration {
    trigger_events = [
      "DeploymentSuccess",
      "DeploymentFailure",
      "DeploymentStop"
    ]
    trigger_name       = "DiscordNotification"
    trigger_target_arn = data.terraform_remote_state.sns.outputs.aws_sns_topic_codedeploy_arn
  }

  tags = {
    Name        = "codedeploy-group-promtheus-${data.terraform_remote_state.vpc.outputs.shard_id}"
    Environment = data.terraform_remote_state.vpc.outputs.billing_tag
  }
}
