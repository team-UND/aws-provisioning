resource "aws_ecr_repository" "default" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "default" {
  count      = var.create_lifecycle_policy ? 1 : 0
  repository = aws_ecr_repository.default.name

  policy = templatefile("${path.module}/ecr_lifecycle_policy.json.tftpl", {
    untagged_image_expiration_days = var.untagged_image_expiration_days
    tagged_image_retention_count   = var.tagged_image_retention_count
  })
}
