output "load-balancer-ip" {
  value = google_compute_address.default.address
}