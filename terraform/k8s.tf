resource "kubernetes_namespace" "product_list" {
  metadata {
    name = "product-list"
  }
}

resource "kubernetes_service" "product_list" {
  metadata {
    namespace = kubernetes_namespace.product_list.metadata[0].name
    name      = "product-list"
  }

  spec {
    selector = {
      app = "product-list"
    }

    session_affinity = "ClientIP"

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 5000
    }

    type             = "LoadBalancer"
    load_balancer_ip = google_compute_address.default.address
  }
}
