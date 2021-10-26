provider "aws" {
  region = var.aws_region
}

module "ecr" {

  source       = "./ecr"
  owner        = var.owner
  repositories = var.repositories
}

output "db_app_repository_name" {
  value = module.ecr.db_app_repository_name
}

output "db_nginx_repository_name" {
  value = module.ecr.db_nginx_repository_name
}

output "s3_app_repository_name" {
  value = module.ecr.s3_app_repository_name
}

output "s3_nginx_repository_name" {
  value = module.ecr.s3_nginx_repository_name
}