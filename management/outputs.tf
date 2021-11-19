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

output "secret_key" {
  value = module.self-hosted-runner.secret_key
  sensitive = true
}

output "access_key" {
  value = module.self-hosted-runner.access_key
}

output "public_subnet_id" {
  value = module.self-hosted-runner.public_subnet_id
}

output "private_subnet_id" {
  value = module.self-hosted-runner.private_subnet_id
}

output "security_group_id" {
  value = module.self-hosted-runner.security_group_id
}