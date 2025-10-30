output "project_id" {
  value = var.project_id
}

output "gcp_region" {
  value = var.gcp_region
}

output "gcp_repo_name" {
  value = var.gcp_repo_name
}

output "gke_cluster_name" {
  value = "cloudshirt-gke"
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}
