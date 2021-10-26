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
        description  = "Keep untagged images for 3 days"
        selection    = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 3
        }

        action = {
          type = "expire"
        }

      }
    ]
  })
}