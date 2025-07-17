module "local" {
  source = "../../_module/local"

  aws_region = var.aws_region

  # If the filter string is left empty, all resources will be searched
  filter_string = ""

  default_view = true
}
