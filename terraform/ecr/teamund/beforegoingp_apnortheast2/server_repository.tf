module "server_repository" {
  source = "../../_module/repository"

  repository_name = "beforegoingp-server"

  create_lifecycle_policy        = true
  untagged_image_expiration_days = 7
  tagged_image_retention_count   = 10
}
