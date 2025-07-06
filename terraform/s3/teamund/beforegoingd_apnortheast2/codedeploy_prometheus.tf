resource "aws_s3_bucket" "codedeploy_artifact_prometheus" {
  bucket = "codedeploy-artifact-prometheus-${data.terraform_remote_state.vpc.outputs.shard_id}"
}

resource "aws_s3_bucket_versioning" "codedeploy_artifact_prometheus" {
  bucket = aws_s3_bucket.codedeploy_artifact_prometheus.id
  versioning_configuration {
    status = "Enabled"
  }
}
