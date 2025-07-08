resource "aws_ecr_repository" "beforegoingd_server_build" {
  name                 = "beforegoingd-server"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
