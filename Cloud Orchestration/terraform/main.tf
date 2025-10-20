module "base" {
  source = "./modules/aws/base_stack"
}

module "rds" {
  source      = "./modules/aws/rds_stack"
  db_password = var.db_password
  depends_on  = [module.base]
}

module "efs" {
  source     = "./modules/aws/efs_stack"
  depends_on = [module.base]
}

module "ecr" {
  source = "./modules/aws/ecr_stack"
}

module "buildserver" {
  source     = "./modules/aws/buildserver_stack"
  depends_on = [module.base]
}

module "loadbalancer" {
  source     = "./modules/aws/loadbalancer_stack"
  depends_on = [module.buildserver]
}

module "elk" {
  source     = "./modules/aws/elk_stack"
  depends_on = [module.buildserver]
}

module "ec2docker" {
  source     = "./modules/aws/ec2docker_stack"
  depends_on = [module.base]
}

