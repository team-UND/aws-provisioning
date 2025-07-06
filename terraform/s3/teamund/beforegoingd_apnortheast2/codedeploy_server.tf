resource "aws_s3_bucket" "codedeploy_artifact_server" {
  bucket = "codedeploy-artifact-server-${data.terraform_remote_state.vpc.outputs.shard_id}"
}

resource "aws_s3_bucket_versioning" "codedeploy_artifact_server" {
  bucket = aws_s3_bucket.codedeploy_artifact_server.id
  versioning_configuration {
    status = "Enabled"
  }
}
