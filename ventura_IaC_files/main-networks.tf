resource "aws_vpc" "ventura-VPC" {
  cidr_block       = var.vpc_cidr_block
  #instance_tenancy = var.instance_tenancy
  tags = {
    Name = "Ventura-Prod-VPC"
  }
}

resource "aws_subnet" "ventura-Subnet" {
  for_each = var.subnet_configs

  vpc_id                  = aws_vpc.ventura-VPC.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  tags = {
    Name = each.key  # Use the subnet name as the Name tag
  }
}


resource "aws_internet_gateway" "Prod_IGW" {
  vpc_id = aws_vpc.ventura-VPC.id

  tags = {
    Name = "Prod_IGW"
  }
}

resource "aws_route_table" "Prod_RTB" {
  vpc_id = aws_vpc.ventura-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Prod_IGW.id
  }

  tags = {
    Name = "Prod_RTB"
  }
}

resource "aws_route_table_association" "subnet_1" {
  subnet_id      = aws_subnet.Ventura-Prod-NAT-ALB-Subnet-1.id
  route_table_id = aws_route_table.Prod_RTB.id
}

resource "aws_route_table_association" "subnet_2" {
  subnet_id      = aws_subnet.Ventura-Prod-ALB-Subnet-2.id
  route_table_id = aws_route_table.Prod_RTB.id
}