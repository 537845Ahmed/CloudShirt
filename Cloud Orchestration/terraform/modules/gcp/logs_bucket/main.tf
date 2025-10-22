resource "google_storage_bucket" "logs" {
  name          = "cloudshirt-central-logs"
  location      = "EU"
  force_destroy = true
}

output "logs_bucket_url" {
  value = "gs://${google_storage_bucket.logs.name}"
}
