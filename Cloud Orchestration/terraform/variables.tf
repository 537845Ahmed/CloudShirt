variable "db_password" {
  description = "Password for RDS database"
  type        = string
  sensitive   = true
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "Region for Artifact Registry and GKE"
  type        = string
  default     = "europe-west4"
}

variable "gcp_repo_name" {
  description = "Artifact Registry repo name"
  type        = string
  default     = "cloudshirt-docker"
}

variable "gcp_service_account_json" {
  description = "Base64-encoded service account key for buildserver"
  type        = string
  default     = ""
  sensitive   = true
}