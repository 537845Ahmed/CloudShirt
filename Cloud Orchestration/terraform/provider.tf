provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

provider "google" {
  credentials = file("${path.root}/gcp-service-account.json")
  project     = var.project_id
  region      = "europe-west4"
  zone        = "europe-west4-a"
}
