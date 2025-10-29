variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
}

variable "gcp_repo_name" {
  description = "Artifact Registry repository name"
  type        = string
}

variable "gcp_service_account_json" {
  description = "Base64 encoded service account JSON"
  type        = string
  default     = ""
}
