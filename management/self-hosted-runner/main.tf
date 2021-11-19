resource "aws_iam_user" "runner" {
  name = "${var.owner}-github-runner"
  path = "/"
}

resource "aws_iam_access_key" "runner" {
  user = aws_iam_user.runner.name
}

resource "aws_iam_user_policy" "runner" {
  name = "${var.owner}-runner-policy"
  user = aws_iam_user.runner.name

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action   = [
          "ec2:TerminateInstances",
          "ec2:RunInstances",
          "ec2:ReplaceIamInstanceProfileAssociation",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:AssociateIamInstanceProfile"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Action" : "iam:PassRole",
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateTags"
        ],
        "Resource" : "*",
        "Condition" : {
          "StringEquals" : {
            "ec2:CreateAction" : "RunInstances"
          }
        }
      }
    ]
  })


}

resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name  = "${var.owner}-${var.PREFIX}-vpc"
    Owner = var.owner
  }
}

resource "aws_internet_gateway" "int_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name  = "${var.owner}-${var.PREFIX}-int-gateway"
    Owner = var.owner
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "eu-west-2a"

  tags = {
    Name  = "${var.owner}-${var.PREFIX}-private-subnet"
    Owner = var.owner
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = "eu-west-2a"

  tags = {
    Name  = "${var.owner}-${var.PREFIX}-public-subnet"
    Owner = var.owner
  }
}

# NAT for private subnet
resource "aws_eip" "nat_gateway_eip" {
  vpc = true

  tags = {
    Name  = "${var.owner}-${var.PREFIX}-nat-gateway-eip"
    Owner = var.owner
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name  = "${var.owner}-${var.PREFIX}-nat-gateway"
    Owner = var.owner
  }
}

# Public route table
resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.int_gateway.id
  }

  tags = {
    Name  = "${var.owner}-${var.PREFIX}-public"
    Owner = var.owner
  }

}

# Private route table
resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name  = "${var.owner}-${var.PREFIX}-private"
    Owner = var.owner
  }


}

# Associations
resource "aws_route_table_association" "assoc_1" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route_table_association" "assoc_2" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.route_table_private.id
}

# Security groups

resource "aws_security_group" "runner" {
  name   = "${var.owner}-${var.PREFIX}-sg-runner"
  vpc_id = aws_vpc.vpc.id

  egress {
    protocol   = "tcp"
    from_port  = 80
    to_port    = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.owner}-${var.PREFIX}-sg-runner"
    Owner = var.owner
  }
}