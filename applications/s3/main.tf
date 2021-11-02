resource "aws_s3_bucket" "app_bucket" {
  bucket = "${var.owner}-bucket"

  force_destroy = true
}

