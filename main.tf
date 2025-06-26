
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region

  node_version       = data.google_container_engine_versions.central1b_stable.latest_node_version
  min_master_version = data.google_container_engine_versions.central1b_stable.latest_master_version

  node_locations = ["us-central1-a", "us-central1-b",]
  # remove_default_node_pool = true
  # node_locations = ["us-central1-b"]
  remove_default_node_pool = false
  initial_node_count       = 1

  network    = var.network
  subnetwork = var.subnetwork

  ip_allocation_policy {}

  deletion_protection = false
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "cpu-node-pool"
  cluster    = google_container_cluster.primary.name
  location   = var.region

  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}