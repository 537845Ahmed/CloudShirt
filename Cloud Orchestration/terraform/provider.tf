provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

 provider "google" {
  credentials = file("${path.root}/gcp-service-account.json")
  project     = "k8-cluster-470912"
  region      = "europe-west4"
  zone        = "europe-west4-a"
}
