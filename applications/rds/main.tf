resource "aws_db_subnet_group" "main" {
  name       = "${var.owner}-db-subnet-group"
  subnet_ids = var.subnets_ids

  tags = {
    Name  = "${var.owner}-db-subnet-group"
    Owner = var.owner
  }
}

resource "random_password" "db_master_pass" {
  length           = 40
  special          = true
  min_special      = 5
  override_special = "!#$%^&*()-_=+[]{}<>:?"
  keepers          = {
    pass_version = 1
  }
}

resource "aws_db_instance" "main" {
  allocated_storage      = 10
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  identifier             = "${var.owner}-db"
  name                   = "postgres"
  username               = "postgres"
  password               = random_password.db_master_pass.result
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = var.security_groups
  skip_final_snapshot    = true

  tags = {
    Name  = "${var.owner}-db"
    Owner = var.owner
  }
}

resource "aws_ssm_parameter" "db_name" {
  name        = "/${var.owner}/database/name"
  description = "Database name"
  type        = "SecureString"
  value       = aws_db_instance.main.name
}

resource "aws_ssm_parameter" "db_user" {
  name        = "/${var.owner}/database/username"
  description = "Database username"
  type        = "SecureString"
  value       = aws_db_instance.main.username
}

resource "aws_ssm_parameter" "db_pass" {
  name        = "/${var.owner}/database/password"
  description = "Database password"
  type        = "SecureString"
  value       = aws_db_instance.main.password
}

resource "aws_ssm_parameter" "db_host" {
  name        = "/${var.owner}/database/host"
  description = "Database host"
  type        = "SecureString"
  value       = aws_db_instance.main.address
}

resource "aws_ssm_parameter" "db_port" {
  name        = "/${var.owner}/database/port"
  description = "Database port"
  type        = "SecureString"
  value       = aws_db_instance.main.port
}

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


