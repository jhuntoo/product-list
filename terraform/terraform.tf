terraform {
  required_version = "0.13.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.50.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 3.50.0"
    }
  }
}

provider "google" {
  project = var.gcp_project
}

provider "google-beta" {
  project = var.gcp_project
}


provider "kubernetes" {
  version = "~> 1.10.0"
  host    = google_container_cluster.cluster.endpoint
  token   = data.google_client_config.current.access_token
  client_certificate = base64decode(
  google_container_cluster.cluster.master_auth[0].client_certificate,
  )
  client_key = base64decode(google_container_cluster.cluster.master_auth[0].client_key)
  cluster_ca_certificate = base64decode(
  google_container_cluster.cluster.master_auth[0].cluster_ca_certificate,
  )
}