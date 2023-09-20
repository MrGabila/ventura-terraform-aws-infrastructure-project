resource "aws_vpc" "Prod_VPC" {
  cidr_block       = var.cidr_block
  instance_tenancy = var.instance_tenancy
  

  tags = {
    Name = "Prod_VPC"
  }
}

resource "aws_subnet" "Ventura-Prod-NAT-ALB-Subnet-1" {
  vpc_id     = aws_vpc.Prod_VPC.id
  cidr_block = var.aws_subnet
  availability_zone = var.availability_zone[0]



  tags = {
    Name = "Ventura-Prod-NAT-ALB-Subnet-1"
  }
}

resource "aws_subnet" "Ventura-Prod-ALB-Subnet-2" {
  vpc_id     = aws_vpc.Prod_VPC.id
  cidr_block = var.aws_subnet1
  availability_zone = var.availability_zone[1]
  


  tags = {
    Name = "Ventura-Prod-ALB-Subnet-2"
  }
}

resource "aws_subnet" "Ventura-Prod-Web-Subnet-1" {
  vpc_id     = aws_vpc.Prod_VPC.id
  cidr_block = var.aws_subnet2
  availability_zone = var.availability_zone[0]
  


  tags = {
    Name = "Ventura-Prod-Web-Subnet-1"
  }
}

resource "aws_subnet" "Ventura-Prod-Web-Subnet-2" {
  vpc_id     = aws_vpc.Prod_VPC.id
  cidr_block = var.aws_subnet3
  availability_zone = var.availability_zone[1]
  


  tags = {
    Name = "Ventura-Prod-Web-Subnet-2"
  }
}

resource "aws_subnet" "Ventura-Prod-App-Subnet-1" {
  vpc_id     = aws_vpc.Prod_VPC.id
  cidr_block = var.aws_subnet4
  availability_zone = var.availability_zone[0]
  


  tags = {
    Name = "Ventura-Prod-App-Subnet-1"
  }
}

resource "aws_subnet" "Ventura-Prod-App-Subnet-2" {
  vpc_id     = aws_vpc.Prod_VPC.id
  cidr_block = var.aws_subnet5
  availability_zone = var.availability_zone[1]
  


  tags = {
    Name = "Ventura-Prod-App-Subnet-2"
  }
}

resource "aws_subnet" "Ventura-Prod-DB-Subnet-1" {
  vpc_id     = aws_vpc.Prod_VPC.id
  cidr_block = var.aws_subnet6
  availability_zone = var.availability_zone[0]
  


  tags = {
    Name = "Ventura-Prod-DB-Subnet-1"
  }
}

resource "aws_subnet" "Ventura-Prod-DB-Subnet-2" {
  vpc_id     = aws_vpc.Prod_VPC.id
  cidr_block = var.aws_subnet7
  availability_zone = var.availability_zone[1]
  


  tags = {
    Name = "Ventura-Prod-DB-Subnet-1"
  }
}

resource "aws_internet_gateway" "Prod_IGW" {
  vpc_id = aws_vpc.Prod_VPC.id

  tags = {
    Name = "Prod_IGW"
  }
}

resource "aws_route_table" "Prod_RTB" {
  vpc_id = aws_vpc.Prod_VPC.id

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