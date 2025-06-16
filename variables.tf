variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "mlops-test"
}

variable "node_count" {
  description = "Number of nodes in the node pool"
  type        = number
  default     = 1
}

variable "machine_type" {
  description = "Machine type for the nodes"
  type        = string
  default     = "e2-standard-2"
}

variable "network" {
  description = "VPC network name"
  type        = string
  default     = "mlops-vpc"
}

variable "subnetwork" {
  description = "Subnetwork name"
  type        = string
  default     = "mlops-subnet"
}

variable "gke_version_prefix" {
  description = "The Kubernetes version to use for the GKE cluster"
  type        = string
  default     = "1.33"
}