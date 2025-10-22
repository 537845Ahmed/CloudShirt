variable "db_password" {
  description = "Password for RDS database"
  type        = string
  sensitive   = true
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}
