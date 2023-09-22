variable "subnet_cidrs" {
    description = "cidr_blocks for the subnets"
    type        = map
    default     = {
        Ventura-Prod-NAT-ALB-Subnet-1 = "10.0.1.0/28" # 11 IPs
        Ventura-Prod-ALB-Subnet-2 = "10.0.3.0/28"

        Ventura-Prod-Web-Subnet-1 = "10.0.5.0/23" # 507 IPs
        Ventura-Prod-Web-Subnet-2 = "10.0.10.0/23"

        Ventura-Prod-App-Subnet-1 = "10.0.15.0/23" # 507 IPs
        Ventura-Prod-App-Subnet-2 = "10.0.20.0/23"

        Ventura-Prod-DB-Subnet-1 = "10.0.25.0/27" # 27 IPs
        Ventura-Prod-DB-Subnet-2 = "10.0.30.0/27"
        }
}

variable "subnet-AZs" {
  description = "subnet names and avaialbility-zones"
  type        = map
  default     = {
    Ventura-Prod-NAT-ALB-Subnet-1 = "us-east-1a" # Usage for Application Load Balancer and NAT gateway
    Ventura-Prod-ALB-Subnet-2 = "us-east-1b" # Usage for Application Load Balancer

    Ventura-Prod-Web-Subnet-1 = "us-east-1a" # Usage for Web agent Servers
    Ventura-Prod-Web-Subnet-2 = "us-east-1b"

    Ventura-Prod-App-Subnet-1 = "us-east-1a" # Usage for App agent Servers
    Ventura-Prod-App-Subnet-2 = "us-east-1b"

    Ventura-Prod-DB-Subnet-1 = "us-east-1a" # Usage for RDS-Mysql DB
    Ventura-Prod-DB-Subnet-2 = "us-east-1b"
    }
}

resource "aws_subnet" "Ventura-Prod-NAT-ALB-Subnet-1" {
  # Usage for Application Load Balancer and NAT gateway
  vpc_id     = aws_vpc.ventura-VPC.id
  cidr_block = "10.0.1.0/28"
  availability_zone = var.availability_zone[0]
  tags = {
    Name = "Ventura-Prod-NAT-ALB-Subnet-1"
  }
}

resource "aws_subnet" "Ventura-Prod-ALB-Subnet-2" {
  # Usage for Application Load Balancer
  vpc_id     = aws_vpc.ventura-VPC.id
  cidr_block = "10.0.3.0/28"
  availability_zone = var.availability_zone[1]
  tags = {
    Name = "Ventura-Prod-ALB-Subnet-2"
  }
}

resource "aws_subnet" "Ventura-Prod-Web-Subnet-1" {
  # Usage for Web agent Servers
  vpc_id     = aws_vpc.ventura-VPC.id
  cidr_block = "10.0.5.0/23"
  availability_zone = var.availability_zone[0]
  tags = {
    Name = "Ventura-Prod-Web-Subnet-1"
  }
}

resource "aws_subnet" "Ventura-Prod-Web-Subnet-2" {
  # Usage for Web agent Servers
  vpc_id     = aws_vpc.ventura-VPC.id
  cidr_block = "10.0.10.0/23"
  availability_zone = var.availability_zone[1]
  tags = {
    Name = "Ventura-Prod-Web-Subnet-2"
  }
}

resource "aws_subnet" "Ventura-Prod-App-Subnet-1" {
  # Usage for App agent Servers
  vpc_id     = aws_vpc.ventura-VPC.id
  cidr_block = "10.0.15.0/23"
  availability_zone = var.availability_zone[0]
  tags = {
    Name = "Ventura-Prod-App-Subnet-1"
  }
}

resource "aws_subnet" "Ventura-Prod-App-Subnet-2" {
  # Usage for App agent Servers
  vpc_id     = aws_vpc.ventura-VPC.id
  cidr_block = "10.0.20.0/23"
  availability_zone = var.availability_zone[1]
  tags = {
    Name = "Ventura-Prod-App-Subnet-2"
  }
}

resource "aws_subnet" "Ventura-Prod-DB-Subnet-1" {
  vpc_id     = aws_vpc.ventura-VPC.id
  cidr_block = "10.0.25.0/27" # 27 Ips
  availability_zone = var.availability_zone[0]
  tags = {
    Name = "Ventura-Prod-DB-Subnet-1"
  }
}

resource "aws_subnet" "Ventura-Prod-DB-Subnet-2" {
  vpc_id     = aws_vpc.ventura-VPC.id
  cidr_block = "10.0.25.0/27" # 27 IPs
  availability_zone = var.availability_zone[1]
  tags = {
    Name = "Ventura-Prod-DB-Subnet-2"
  }
}

resource "aws_route_table_association" "subnet_ALB" {
  subnet_id      = aws_subnet.Ventura-Prod-ALB-Subnet-2.id
  route_table_id = aws_route_table.ventura-RT.id
}

# Retrieve the Subnet Ids 
locals { 
  web-subnets = [aws_subnet.Web-Subnets["Ventura-Prod-Web-Subnet-1"].id, aws_subnet.Web-Subnets["Ventura-Prod-Web-Subnet-2"].id]
  app-subnets = [aws_subnet.App-Subnets["Ventura-Prod-App-Subnet-1"].id, aws_subnet.App-Subnets["Ventura-Prod-App-Subnet-2"].id]
  db-subnets = [aws_subnet.db-Subnets["Ventura-Prod-DB-Subnet-1"].id, aws_subnet.db-Subnets["Ventura-Prod-DB-Subnet-2"].id]
}

# Create the Web Servers
resource "aws_instance" "web-servers" {
    count = var.prod-server-count
    ami = data.aws_ami.CentOS7
    instance_type = var.instance_type
    subnet_id     = element(values(local.web-subnets), count.index % length(local.web-subnets))
    
    tags {
        tags = var.server-tags
        Name = "${var.Name}-web-${count.index}"
    }
}

# Create the App Servers
resource "aws_instance" "app-servers" {
    count = var.prod-server-count
    ami = data.aws_ami.CentOS7
    instance_type = var.instance_type
    subnet_id     = element(values(local.app-subnets), count.index % length(local.app-subnets))
    root_block_device {
      volume_size = 250
    }
    tags {
        tags = var.server-tags
        Name = "${var.Name}-app-${count.index}"
    }
}