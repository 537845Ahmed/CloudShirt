provider "aws" {
  region  = "eu-west-1"
  profile = "default"
}

provider "google" {
  credentials = file("${path.root}/gcp-service-account.json")
  project     = "cloudshirt-project"
  region      = "europe-west4"
  zone        = "europe-west4-a"
}
