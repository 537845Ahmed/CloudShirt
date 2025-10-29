variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "Region for GCP Artifact Registry"
  type        = string
}

variable "gcp_repo_name" {
  description = "Artifact Registry repo name"
  type        = string
}
