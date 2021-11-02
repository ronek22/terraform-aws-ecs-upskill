output "bastion" {
  value = aws_security_group.bastion.id
}

output "alb" {
  value = aws_security_group.alb.id
}

output "s3_app" {
  value = aws_security_group.s3_app.id
}

output "db_app" {
  value = aws_security_group.db_app.id
}

output "rds" {
  value = aws_security_group.rds.id
}