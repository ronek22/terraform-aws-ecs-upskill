output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}

output "security_group_id" {
  value = aws_security_group.runner.id
}

output "access_key" {
  value = aws_iam_access_key.runner.id
}

output "secret_key" {
  value = aws_iam_access_key.runner.secret
  sensitive = true
}