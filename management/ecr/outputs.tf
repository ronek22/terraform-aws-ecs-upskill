output "db_app_repository_name" {
  value = aws_ecr_repository.main.0.name
}

output "db_nginx_repository_name" {
  value = aws_ecr_repository.main.1.name
}

output "s3_app_repository_name" {
  value = aws_ecr_repository.main.2.name
}

output "s3_nginx_repository_name" {
  value = aws_ecr_repository.main.3.name
}