resource "aws_ecr_repository" "beforegoingd_prometheus_build" {
  name                 = "beforegoingd-prometheus"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
