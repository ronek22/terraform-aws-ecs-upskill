resource "aws_s3_bucket" "app_bucket" {
  bucket = "${var.owner}-bucket"

  force_destroy = true
}

output "bucket_arn" {
  value = aws_s3_bucket.app_bucket.arn
}

output "bucket_name" {
  value = aws_s3_bucket.app_bucket.bucket
}