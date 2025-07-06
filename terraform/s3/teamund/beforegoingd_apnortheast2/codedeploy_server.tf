resource "aws_s3_bucket" "codedeploy_artifact" {
  bucket = "codedeploy-artifact-server-${data.terraform_remote_state.vpc.outputs.shard_id}"
}

resource "aws_s3_bucket_versioning" "codedeploy_artifact" {
  bucket = aws_s3_bucket.codedeploy_artifact.id
  versioning_configuration {
    status = "Enabled"
  }
}
