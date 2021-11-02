resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name  = "${var.owner}-vpc"
    Owner = var.owner
  }
}


resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name  = "${var.owner}-igw"
    Owner = var.owner
  }
}

resource "aws_nat_gateway" "main" {
  count         = length(var.public_subnets)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  depends_on    = [aws_internet_gateway.main]

  tags = {
    Name  = "${var.owner}-nat-${format("%03d", count.index+1)}"
    Owner = var.owner
  }
}

resource "aws_eip" "nat" {
  count = length(var.public_subnets)
  vpc   = true

  tags = {
    Name  = "${var.owner}-eip-${format("%03d", count.index+1)}"
    Owner = var.owner
  }
}

# PUBLIC SUBNETS

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  count                   = length(var.public_subnets)
  map_public_ip_on_launch = true

  tags = {
    Name  = "${var.owner}-${element(var.public_subnets_names, count.index)}"
    Owner = var.owner
  }

}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name  = "${var.owner}-route-table-public"
    Owner = var.owner
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# PRIVATE SUBNETS

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  count             = length(var.private_subnets)

  tags = {
    Name  = "${var.owner}-${element(var.private_subnets_names, count.index)}"
    Owner = var.owner
  }
}


# 2 Private Route Tables for 2 AZ
resource "aws_route_table" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.main.id

  tags = {
    Name  = "${var.owner}-route-table-private-${element(var.availability_zones, count.index)}"
    Owner = var.owner
  }
}

resource "aws_route" "private" {
  count                  = length(compact(var.availability_zones))
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.main.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index % 2)
}


