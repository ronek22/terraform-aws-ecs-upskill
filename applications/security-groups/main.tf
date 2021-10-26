resource "aws_security_group" "bastion" {
  name   = "${var.owner}-sg-bastion"
  vpc_id = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.owner}-sg-bastion"
    Owner = var.owner
  }
}

resource "aws_security_group" "alb" {
  name   = "${var.owner}-sg-alb"
  vpc_id = var.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.owner}-sg-alb"
    Owner = var.owner
  }
}

resource "aws_security_group" "s3_app" {
  name   = "${var.owner}-sg-s3-app"
  vpc_id = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    security_groups = ["${aws_security_group.bastion.id}"]
  }

  ingress {
    description = "http"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.owner}-sg-s3-app"
    Owner = var.owner
  }
}

resource "aws_security_group" "db_app" {
  name   = "${var.owner}-sg-db-app"
  vpc_id = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    security_groups = ["${aws_security_group.bastion.id}"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.owner}-sg-db-app"
    Owner = var.owner
  }
}

resource "aws_security_group" "rds" {
  name   = "${var.owner}-sg-rds"
  vpc_id = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    security_groups = ["${aws_security_group.db_app.id}"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.owner}-sg-rds"
    Owner = var.owner
  }
}

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