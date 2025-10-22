resource "google_storage_bucket" "logs" {
  name          = "cloudshirt-logs-${random_id.suffix.hex}"
  location      = "EU"
  force_destroy = true
}

resource "random_id" "suffix" {
  byte_length = 4
}

output "logs_bucket_url" {
  value = "gs://${google_storage_bucket.logs.name}"
}
