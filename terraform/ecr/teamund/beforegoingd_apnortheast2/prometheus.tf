resource "aws_ecr_repository" "prometheus_build" {
  name                 = "beforegoing-prometheus"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
