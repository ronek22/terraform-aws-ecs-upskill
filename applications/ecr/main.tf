data "aws_ecr_repository" "service" {
  count = length(var.repositories)
  name  = "${var.owner}-${element(var.repositories, count.index)}"
}


