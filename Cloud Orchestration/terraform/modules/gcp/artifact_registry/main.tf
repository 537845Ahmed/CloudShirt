resource "google_artifact_registry_repository" "cloudshirt_repo" {
  location      = "europe-west4"
  repository_id = "cloudshirt-repo"
  description   = "Artifact Registry for CloudShirt images"
  format        = "DOCKER"
}

output "artifact_repo_url" {
  value = google_artifact_registry_repository.cloudshirt_repo.repository_id
}
