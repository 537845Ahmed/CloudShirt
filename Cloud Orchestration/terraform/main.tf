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
  source     = "./modules/aws/buildserver_stack"
  depends_on = [module.rds]
}


######################################
# GCP modules
######################################

module "network" {
  source = "./modules/gcp/network"
}

module "artifact_registry" {
  source     = "./modules/gcp/artifact_registry"
  depends_on = [module.network]
}

module "gke_cluster" {
  source     = "./modules/gcp/gke_cluster"
  vpc_id     = module.network.vpc_id
  subnet_id  = module.network.subnet_id 
  depends_on = [module.network]
}

module "loadbalancer" {
  source     = "./modules/gcp/loadbalancer"
  depends_on = [module.gke_cluster]
}
