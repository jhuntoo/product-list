provider "google" {
  version = "~> 3.50.0"
  project = var.gcp_project
}

provider "google-beta" {
  version = "~> 3.50.0"
  project = var.gcp_project
}