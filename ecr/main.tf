resource "aws_ecr_repository" "main" {
  count                = length(var.repositories)
  name                 = "${var.owner}-${element(var.repositories, count.index)}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}


resource "aws_ecr_lifecycle_policy" "main" {
  count      = length(var.repositories)
  repository = aws_ecr_repository.main.*.name[count.index]
  depends_on = [aws_ecr_repository.main]

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "keep last 10 images"
        action       = {
          type = "expire"
        }
        selection    = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
      }
    ]
  })
}

output "db_app_repository_url" {
  value = aws_ecr_repository.main.0.repository_url
}

output "db_nginx_repository_url" {
  value = aws_ecr_repository.main.1.repository_url
}

output "s3_app_repository_url" {
  value = aws_ecr_repository.main.2.repository_url
}

output "s3_nginx_repository_url" {
  value = aws_ecr_repository.main.3.repository_url
}