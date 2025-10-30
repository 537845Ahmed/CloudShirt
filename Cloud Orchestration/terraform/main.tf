######################################
# GCP modules
######################################

module "network" {
  source = "./modules/gcp/network"
}

module "artifact_registry" {
  source       = "./modules/gcp/artifact_registry"
  project_id   = var.project_id
  gcp_region   = var.gcp_region
  gcp_repo_name = var.gcp_repo_name
  depends_on   = [module.network]   # <-- eerst netwerk
}

module "gke_cluster" {
  source     = "./modules/gcp/gke_cluster"
  vpc_id     = module.network.vpc_id
  subnet_id  = module.network.subnet_id 
  depends_on = [module.artifact_registry]  # <-- pas na artifact
}

module "loadbalancer" {
  source     = "./modules/gcp/loadbalancer"
  depends_on = [module.gke_cluster]
}



######################################
# AWS modules
######################################

module "base" {
  source = "./modules/aws/base_stack"
}

module "rds" {
  source      = "./modules/aws/rds-stack"
  db_password = var.db_password
  depends_on  = [module.base]
}

module "efs" {
  source     = "./modules/aws/efs_stack"
  depends_on = [module.base]
}

module "elk" {
  source     = "./modules/aws/elk_stack"
  depends_on = [module.base]
}

module "buildserver" {
  source                   = "./modules/aws/buildserver_stack"
  project_id               = var.project_id
  gcp_region               = var.gcp_region
  gcp_repo_name            = var.gcp_repo_name
  gcp_service_account_json = var.gcp_service_account_json
  depends_on               = [module.efs, module.rds, module.elk] # <-- wacht tot infra klaar is
}
