resource "google_artifact_registry_repository" "cloudshirt_repo" {
  project       = var.project_id
  location      = var.gcp_region
  repository_id = var.gcp_repo_name
  description   = "Artifact Registry for CloudShirt images"
  format        = "DOCKER"
}

output "artifact_repo_url" {
  value = google_artifact_registry_repository.cloudshirt_repo.repository_id
}
