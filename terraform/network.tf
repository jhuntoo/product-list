
resource "google_compute_address" "default" {
  name   = var.stack_prefix
  region = var.region
}

resource "google_compute_network" "default" {
  name                    = var.stack_prefix
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  name                     =  var.stack_prefix
  ip_cidr_range            = "10.132.0.0/20"  // Change as per your region/zone
  network                  = google_compute_network.default.self_link
  region                   = var.region
  private_ip_google_access = true
}





data "google_client_config" "current" {
}

