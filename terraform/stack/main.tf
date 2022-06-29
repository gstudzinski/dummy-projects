locals {
  tags = {
    Terraform = "true"
    Environment = var.environment
    Owner = var.owner
  }

  mod_prefix = "${var.prefix}-${var.environment}"
}

module "vpc" {
  source  = "../modules/vpc"

  mod_prefix = local.mod_prefix
  vpc_cidr = var.vpc_cidr

  region = var.region
  tags = local.tags

}

module "rds_db" {
  source  = "../modules/rds_db"

  mod_prefix = local.mod_prefix

  vpc_cidr = var.vpc_cidr
  vpc_id = module.vpc.vpc_id
  subnet_group_name = module.vpc.database_subnet_group_name

  db_name = var.db_name
  username = var.db_user
  password = var.db_password
  port = var.db_port

  tags = local.tags
}

module "ecs_cluster" {
  source  = "../modules/ecs_cluster"

  mod_prefix = local.mod_prefix

  vpc_id = module.vpc.vpc_id

  tags = local.tags
}

module "alb" {
  source  = "../modules/alb"

  mod_prefix = local.mod_prefix

  vpc_id = module.vpc.vpc_id
  vpc_cidr = var.vpc_cidr
  public_subnets = module.vpc.public_subnets

  target_group_definitions = [
    {
      name          = "app-db-tg-tf"
      port          = var.app_db_port
      health_check  = var.app_db_health
      root_path     = var.app_db_root_path
    },
    {
      name          = "app-s3-tg-tf"
      port          = var.app_s3_port
      health_check  = var.app_s3_health
      root_path     = var.app_s3_root_path
    }
  ]

  tags = local.tags
}

module "app_db" {
  source  = "../modules/app_db"

  mod_prefix = local.mod_prefix

  region = var.region
  vpc_id = module.vpc.vpc_id
  vpc_cidr = var.vpc_cidr
  private_subnets = module.vpc.private_subnets
  ecs_cluster_id = module.ecs_cluster.cluster_id

  service_discovery_namespace_id = module.ecs_cluster.service_discovery_namespace_id

  target_group_arn = module.alb.target_group_arns[0]

  ecr_image = var.app_db_image
  port = var.app_db_port

  db_host = module.rds_db.db_instance_endpoint
  db_password = var.db_password

  tags = local.tags
}

module "app_s3" {
  source  = "../modules/app_s3"

  mod_prefix = local.mod_prefix

  region = var.region
  vpc_id = module.vpc.vpc_id
  vpc_cidr = var.vpc_cidr
  private_subnets = module.vpc.private_subnets
  ecs_cluster_id = module.ecs_cluster.cluster_id

  service_discovery_namespace_id = module.ecs_cluster.service_discovery_namespace_id

  target_group_arn = module.alb.target_group_arns[1]

  ecr_image = var.app_s3_image
  port = var.app_s3_port

  app_db_svc_domain = "${module.app_db.service_name}.${module.ecs_cluster.service_discovery_domain_name}"
  app_db_svc_port = var.app_db_port

  tags = local.tags
}
