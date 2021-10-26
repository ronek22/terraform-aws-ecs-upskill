data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "pem_file" {
  filename             = pathexpand("~/.ssh/${var.key_name}.pem")
  file_permission      = "400"
  directory_permission = "700"
  sensitive_content    = tls_private_key.pk.private_key_pem
}

resource "aws_instance" "bastion" {
  count                  = length(var.availability_zones)
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnets[count.index].id
  vpc_security_group_ids = var.security_groups
  key_name               = aws_key_pair.generated_key.key_name

  tags = {
    Name = "${var.owner}-bastion-${element(var.availability_zones, count.index)}"
    Owner = var.owner
  }
}