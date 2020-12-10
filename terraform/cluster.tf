resource "random_string" "np_name" {
  count   = var.nodepool_count
  length  = 6
  special = false
  upper   = false

  keepers = {
    index              = count.index
    region             = var.region
    cluster            = google_container_cluster.cluster.name
    machine_type       = var.machine_type
    preemptible        = var.preemptible
    initial_node_count = var.initial_node_count
  }

  lifecycle {
    ignore_changes = [keepers.initial_node_count]
  }
}

resource "google_container_cluster" "cluster" {
  provider = google-beta
  name     = "${var.stack_prefix}-cluster"
  location = var.region
  min_master_version = var.master_version
  initial_node_count       = 1
  remove_default_node_pool = true

  network            = google_compute_network.default.name
  subnetwork         = google_compute_subnetwork.default.name

  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }

    username = ""
    password = ""
  }

  lifecycle {
    ignore_changes = [
      min_master_version,
      initial_node_count
    ]
  }
}

resource "google_container_node_pool" "main" {
  provider = google-beta
  count    = var.nodepool_count
  name     = "main-${random_string.np_name.*.result[count.index]}"
  location = random_string.np_name.*.keepers.region[count.index]
  cluster  = random_string.np_name.*.keepers.cluster[count.index]

  initial_node_count = var.initial_node_count
  version            = var.nodepool_version

  node_config {
    machine_type    = random_string.np_name.*.keepers.machine_type[count.index]
    service_account = google_service_account.cluster.email
    preemptible     = var.preemptible
    oauth_scopes    = [ "https://www.googleapis.com/auth/cloud-platform" ]
    labels = {
      preemptible = var.preemptible
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  workload_metadata_config {
    node_metadata = "GKE_METADATA_SERVER"
  }

  management {
    auto_repair  = true
    auto_upgrade = false
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [initial_node_count]
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "${path.module}/scripts/drain_nodepool.sh 'main' '${count.index}' '${google_container_cluster.cluster.name}' '${var.region}' '${var.gcp_project}'"
  }
}

# https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster#use_least_privilege_sa
resource "google_service_account" "cluster" {
  account_id   = "${var.stack_prefix}-cluster"
  display_name = "Default service account for nodes of cluster ${google_container_cluster.cluster.name}"
}

resource "google_project_iam_member" "gke_node_logwriter" {
  member = "serviceAccount:${google_service_account.cluster.email}"
  role   = "roles/logging.logWriter"
}

resource "google_project_iam_member" "gke_node_metricwriter" {
  member = "serviceAccount:${google_service_account.cluster.email}"
  role   = "roles/monitoring.metricWriter"
}

resource "google_project_iam_member" "gke_node_monitoringviewer" {
  member = "serviceAccount:${google_service_account.cluster.email}"
  role   = "roles/monitoring.viewer"
}

resource "google_storage_bucket_iam_member" "gke_node_gcr_viewer" {
  bucket = "eu.artifacts.${var.gcp_project}.appspot.com"
  member = "serviceAccount:${google_service_account.cluster.email}"
  role   = "roles/storage.objectViewer"
}
