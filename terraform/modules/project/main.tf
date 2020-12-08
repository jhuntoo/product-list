locals {
  required_apis = [
    "iam",
    "compute",
    "container",
  ]
}

resource "google_project_service" "api" {
  count              = length(local.required_apis)
  service            = "${local.required_apis[count.index]}.googleapis.com"
  disable_on_destroy = false
}