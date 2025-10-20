resource "google_container_cluster" "primary" {
  name     = "cloudshirt-gke"
  location = "europe-west4"
  network  = module.network.vpc_id

  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {}
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = "europe-west4"
  cluster    = google_container_cluster.primary.name

  node_count = 3  # GKE autoscales later if needed

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

output "cluster_name" {
  value = google_container_cluster.primary.name
}
