resource "aws_ecr_repository" "build" {
  name                 = "beforegoing-build"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
