##################################
# Availability Zones
##################################
data "aws_availability_zones" "azs" {
  state = "available"
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

##################################
# VPC
##################################
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.vpc_name}-vpc"
  }
}

##################################
# Internet Gateway
##################################
resource "aws_internet_gateway" "igw" {
  count = var.enable_igw ? 1 : 0

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

##################################
# PUBLIC SUBNETS
##################################
resource "aws_subnet" "public" {
  count             = length(var.public_subnets_cidr)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnets_cidr[count.index]
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = {
    Name = "${var.vpc_name}-public-${count.index + 1}"
  }
}

##################################
# PRIVATE SUBNETS
##################################
resource "aws_subnet" "private" {
  count             = length(var.private_subnets_cidr)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnets_cidr[count.index]
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = {
    Name = "${var.vpc_name}-private-${count.index + 1}"
  }
}

##################################
# NAT EIP
##################################
resource "aws_eip" "nat_eip" {
  count  = var.enable_nat ? 1 : 0
  domain = "vpc"

  tags = {
    Name = "${var.vpc_name}-nat-eip"
  }
}

##################################
# NAT Gateway
##################################
resource "aws_nat_gateway" "nat" {
  count = var.enable_nat ? 1 : 0

  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = element(aws_subnet.public[*].id, 0)

  tags = {
    Name = "${var.vpc_name}-nat-gw"
  }
}

##################################
# PUBLIC ROUTE TABLE
##################################
resource "aws_route_table" "public" {
  count  = length(var.public_subnets_cidr) > 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route" "public_igw" {
  count = var.enable_igw && length(var.public_subnets_cidr) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
}

resource "aws_route_table_association" "public_assoc" {
  count = length(var.public_subnets_cidr)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

##################################
# PRIVATE ROUTE TABLE
##################################
resource "aws_route_table" "private" {
  count  = length(var.private_subnets_cidr) > 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

resource "aws_route" "private_nat" {
  count = var.enable_nat && length(var.private_subnets_cidr) > 0 ? 1 : 0

  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[0].id
}

resource "aws_route_table_association" "private_assoc" {
  count = length(var.private_subnets_cidr)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}
