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

module "elk" {
  source     = "./modules/aws/elk_stack"
  depends_on = [module.buildserver]
}


