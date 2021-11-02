output "id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = aws_subnet.public
}

output "private_subnets" {
  value = aws_subnet.private
}

output "app_subnets_ids" {
  value = [aws_subnet.private.0.id, aws_subnet.private.1.id]
}

output "database_subnets_ids" {
  value = [aws_subnet.private.2.id, aws_subnet.private.3.id]
}
