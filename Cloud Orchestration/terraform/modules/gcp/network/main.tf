resource "google_compute_network" "vpc" {
  name                    = "cloudshirt-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "cloudshirt-subnet"
  region        = "europe-west4"
  network       = google_compute_network.vpc.id
  ip_cidr_range = "10.0.0.0/16"
}

output "vpc_id" {
  value = google_compute_network.vpc.id
}

output "subnet_id" {
  value = google_compute_subnetwork.subnet.id
}
