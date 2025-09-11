# VPC
# Whole network cidr will be 10.0.0.0/8 
# A VPC cidr will use the B class with 10.xxx.0.0/16
resource "aws_vpc" "default" {
  cidr_block           = "10.${var.cidr_numeral}.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-${var.vpc_name}"
  }
}

# Internet gateway
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "igw-${var.vpc_name}"
  }
}

# NAT gateway
resource "aws_nat_gateway" "default" {
  count = var.enable_ha_nat_gateway ? length(var.availability_zones) : 1

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "nat-gw${count.index}-${var.vpc_name}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP for NAT gateway
resource "aws_eip" "nat" {
  count  = var.enable_ha_nat_gateway ? length(var.availability_zones) : 1
  domain = "vpc"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "nat-eip${count.index}-${var.vpc_name}"
  }
}

# Public subnets
# Subnet will use cidr with /20
# The number of available IP is 4,096 (Including reserved IP from AWS)
resource "aws_subnet" "public" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.default.id

  cidr_block        = "10.${var.cidr_numeral}.${var.cidr_numeral_public[count.index]}.0/20"
  availability_zone = var.availability_zones[count.index]

  # Public IP will be assigned automatically when the instance is lauched in the public subnet
  map_public_ip_on_launch = true

  tags = {
    Name = "public${count.index}-${var.vpc_name}"
  }
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name    = "public-rt-${var.vpc_name}"
    Network = "Public"
  }
}

# Route table association for public subnets
resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private subnets
# Subnet will use cidr with /20
# The number of available IP is 4,096 (Including reserved IP from AWS)
resource "aws_subnet" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.default.id

  cidr_block        = "10.${var.cidr_numeral}.${var.cidr_numeral_private[count.index]}.0/20"
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name    = "private${count.index}-${var.vpc_name}"
    Network = "Private"
  }
}

# Route table for private subnets
resource "aws_route_table" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.default.id

  tags = {
    Name    = "private${count.index}-rt-${var.vpc_name}"
    Network = "Private"
  }
}

# Route table association for private subnets
resource "aws_route_table_association" "private" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# DB private subnets
# This subnet is only for the database
# This subnet will not use NAT gateway
# Subnet will use cidr with /20
# The number of available IP is 4,096 (Including reserved IP from AWS)
resource "aws_subnet" "private_db" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.default.id

  cidr_block        = "10.${var.cidr_numeral}.${var.cidr_numeral_private_db[count.index]}.0/20"
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name    = "private${count.index}db-${var.vpc_name}"
    Network = "Private"
  }
}

# Route table for DB subnets
resource "aws_route_table" "private_db" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.default.id

  tags = {
    Name    = "privatedb${count.index}-rt-${var.vpc_name}"
    Network = "Private"
  }
}

# Route table association for DB subnets
resource "aws_route_table_association" "private_db" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_db[count.index].id
}

# Observability private subnets
# This subnet is for observability tools like Prometheus
# Subnet will use cidr with /24
# The number of available IP is 256 (Including reserved IP from AWS)
resource "aws_subnet" "private_observability" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.default.id

  cidr_block        = "10.${var.cidr_numeral}.${var.cidr_numeral_private_observability[count.index]}.0/24"
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name    = "private${count.index}observability-${var.vpc_name}"
    Network = "Private"
  }
}

# Route table for DB subnets
resource "aws_route_table" "private_observability" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.default.id

  tags = {
    Name    = "privateobservability${count.index}-rt-${var.vpc_name}"
    Network = "Private"
  }
}

# Route table association for observability subnets
resource "aws_route_table_association" "private_observability" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private_observability[count.index].id
  route_table_id = aws_route_table.private_observability[count.index].id
}
