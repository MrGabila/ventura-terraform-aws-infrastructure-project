resource "aws_vpc" "ventura-VPC" {
  cidr_block = var.vpc_cidr_block
  #instance_tenancy = var.instance_tenancy
  tags = {
    Name = "${var.Name}-VPC"
  }
}

# Define a public subnet for the load balancer and bastion host
resource "aws_subnet" "ALB-Subnets" {
  for_each = var.ALB_subnet_configs

  vpc_id                  = aws_vpc.ventura-VPC.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = each.key # Use the subnet name as the Name tag
  }
}

resource "aws_subnet" "Web-Subnets" {
  for_each = var.web_subnet_configs

  vpc_id            = aws_vpc.ventura-VPC.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = each.key # Use the subnet name as the Name tag
  }
}

resource "aws_subnet" "App-Subnets" {
  for_each = var.app_subnet_configs

  vpc_id            = aws_vpc.ventura-VPC.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = each.key # Use the subnet name as the Name tag
  }
}

resource "aws_subnet" "db-Subnets" {
  for_each = var.db_subnet_configs

  vpc_id            = aws_vpc.ventura-VPC.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = {
    Name = each.key # Use the subnet name as the Name tag
  }
}
