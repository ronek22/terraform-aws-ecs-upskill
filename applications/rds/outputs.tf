output "db_name_arn" {
  value = aws_ssm_parameter.db_name.arn
}

output "db_user_arn" {
  value = aws_ssm_parameter.db_user.arn
}

output "db_password_arn" {
  value = aws_ssm_parameter.db_pass.arn
}

output "db_host_arn" {
  value = aws_ssm_parameter.db_host.arn
}

output "db_port_arn" {
  value = aws_ssm_parameter.db_port.arn
}
