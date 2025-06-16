data "google_container_engine_versions" "central1b_stable" {
  provider       = google-beta
  location       = "us-central1-b"
  version_prefix = var.gke_version_prefix
}

output "regular_channel_latest_version" {
  value = data.google_container_engine_versions.central1b_stable.release_channel_latest_version["REGULAR"]
}

output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "kubernetes_endpoint" {
  value = google_container_cluster.primary.endpoint
}
