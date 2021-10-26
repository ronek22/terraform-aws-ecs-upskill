provider "aws" {
  region = var.aws_region
}


module "vpc" {
  source                = "./vpc"
  owner                 = var.owner
  cidr                  = var.cidr
  public_subnets        = var.public_subnets
  public_subnets_names  = var.public_subnets_names
  private_subnets       = var.private_subnets
  private_subnets_names = var.private_subnets_names
  availability_zones    = var.availability_zones
}

module "security_groups" {
  source = "./security-groups"
  owner  = var.owner
  vpc_id = module.vpc.id
}

module "ecr" {
  source       = "./ecr"
  owner        = var.owner
  repositories = var.repositories
}

module "alb" {
  source              = "./alb"
  alb_security_groups = [module.security_groups.alb]
  health_check_paths  = var.health_check_paths
  owner               = var.owner
  subnets             = module.vpc.public_subnets
  target_groups       = var.target_groups
  vpc_id              = module.vpc.id
}

module "bastion" {
  source = "./bastion"

  availability_zones = var.availability_zones
  subnets            = module.vpc.public_subnets
  security_groups    = [module.security_groups.bastion]
  owner              = var.owner
  instance_type      = var.instance_type
  key_name           = var.key_name
}

module "rds" {
  source          = "./rds"
  owner           = var.owner
  subnets_ids     = module.vpc.database_subnets_ids
  security_groups = [module.security_groups.rds]
}

module "s3" {
  source = "./s3"

  owner = var.owner
}

module "iam" {
  source = "./iam"

  aws_region = var.aws_region
  bucket_arn = module.s3.bucket_arn
  owner      = var.owner
}


module "ecs" {

  source = "./ecs"
  owner  = var.owner

  container_cpu      = var.container_cpu
  container_memory   = var.container_memory
  execution_role_arn = module.iam.ecs_task_execution_role_arn
  app_subnets        = module.vpc.app_subnets_ids


  db_app_version          = var.db_app_version
  db_app_repository_url   = module.ecr.db_app_repository_url
  db_nginx_repository_url = module.ecr.db_nginx_repository_url

  db_name_arn     = module.rds.db_name_arn
  db_host_arn     = module.rds.db_host_arn
  db_password_arn = module.rds.db_password_arn
  db_port_arn     = module.rds.db_port_arn
  db_user_arn     = module.rds.db_user_arn

  db_app_desired_count  = 2
  db_app_security_group = [module.security_groups.db_app]
  db_target_group       = module.alb.db_app_target_group_arn

  s3_app_version          = var.s3_app_version
  s3_app_repository_url   = module.ecr.s3_app_repository_url
  s3_nginx_repository_url = module.ecr.s3_nginx_repository_url

  s3_app_security_group = [module.security_groups.s3_app]
  s3_desired_count      = 2
  s3_target_group       = module.alb.s3_app_target_group_arn
  s3_task_role_arn      = module.iam.ecs_task_role_arn
  s3_bucket_name        = module.s3.bucket_name
}

output "alb_url" {
  value = module.alb.alb_dns_url
}