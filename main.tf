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
  source = "./rds"
  owner  = var.owner
  subnets_ids = module.vpc.database_subnets_ids
  security_groups = [module.security_groups.rds]
}