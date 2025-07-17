locals {
  filter_name = var.filter_string == "" ? "all-resources" : var.filter_string
}

resource "aws_resourceexplorer2_index" "default" {
  type = "LOCAL"
}

resource "aws_resourceexplorer2_view" "default" {
  name = "view-${local.filter_name}-${var.aws_region}"

  filters {
    filter_string = var.filter_string
  }

  # Include tag information in the view
  included_property {
    name = "tags"
  }

  default_view = var.default_view

  tags = {
    Name = "view-${local.filter_name}"
  }

  depends_on = [aws_resourceexplorer2_index.default]
}
