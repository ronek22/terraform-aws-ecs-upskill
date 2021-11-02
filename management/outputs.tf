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

output "state_bucket" {
  value = module.state.bucket
}

output "dynamodb_lock" {
  value = module.state.lock_table
}