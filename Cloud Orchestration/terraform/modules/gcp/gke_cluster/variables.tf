variable "vpc_id" {
  description = "ID of the VPC network where the GKE cluster will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Subnetwork ID for the GKE cluster"
  type        = string
}
