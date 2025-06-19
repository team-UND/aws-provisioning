# AWS kms Key
resource "aws_kms_key" "deployment_common" {
  description             = "KMS key for common secrets in ${data.terraform_remote_state.vpc.outputs.aws_region}."
  enable_key_rotation     = true
  deletion_window_in_days = 7
  rotation_period_in_days = 90
}

# Alias for custom key
resource "aws_kms_alias" "deployment_common_kms_alias" {
  name          = "alias/deployment-common"
  target_key_id = aws_kms_key.deployment_common.key_id
}
