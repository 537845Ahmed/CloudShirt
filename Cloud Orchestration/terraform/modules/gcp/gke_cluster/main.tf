resource "google_container_cluster" "primary" {
  name        = "cloudshirt-gke"
  location    = "europe-west4"
  network     = var.vpc_id
  subnetwork  = var.subnet_id

  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {}

  deletion_protection = false

}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = "europe-west4"
  cluster    = google_container_cluster.primary.name

  node_count = 2  # GKE autoscales later if needed

  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 30
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

output "cluster_name" {
  value = google_container_cluster.primary.name
}
