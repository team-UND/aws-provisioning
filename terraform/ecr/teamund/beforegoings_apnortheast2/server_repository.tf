module "server_repository" {
  source = "../../_module/repository"

  repository_name = "beforegoings-server"

  create_lifecycle_policy        = true
  untagged_image_expiration_days = 3
  tagged_image_retention_count   = 4
}
