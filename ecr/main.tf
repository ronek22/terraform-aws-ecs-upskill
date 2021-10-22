data "aws_ecr_repository" "service" {
  count = length(var.repositories)
  name  = "${var.owner}-${element(var.repositories, count.index)}"
}


output "db_app_repository_url" {
  value = data.aws_ecr_repository.service.0.repository_url
}

output "db_nginx_repository_url" {
  value = data.aws_ecr_repository.service.1.repository_url
}

output "s3_app_repository_url" {
  value = data.aws_ecr_repository.service.2.repository_url
}

output "s3_nginx_repository_url" {
  value = data.aws_ecr_repository.service.3.repository_url
}