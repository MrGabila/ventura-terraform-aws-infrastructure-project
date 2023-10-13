data "aws_ami" "CentOS7" {
  most_recent = true

  filter {
    name   = "image-id"
    values = ["ami-002070d43b0a4f171"]
  }

  # filter {
  #   name   = "owner-alias"
  #   values = ["aws-marketplace"]
  # }
}

variable "Name" {
  type    = string
  default = "Ventura-Prod"
}





variable "ALB_subnet_configs" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = {
    Ventura-Prod-NAT-ALB-Subnet-1 = {   # Usage for Application Load Balancer and NAT gateway
      cidr_block        = "10.0.1.0/28" # 11 IPs
      availability_zone = "us-east-1a"
    }
    Ventura-Prod-ALB-Subnet-2 = { # Usage for Application Load Balancer
      cidr_block        = "10.0.3.0/28"
      availability_zone = "us-east-1b"
    }
  }
}

variable "app_subnet_configs" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = {
    Ventura-Prod-App-Subnet-1 = {        # Usage for App agent Servers
      cidr_block        = "10.0.14.0/23" # 507 IPs
      availability_zone = "us-east-1a"
    }
    Ventura-Prod-App-Subnet-2 = {
      cidr_block        = "10.0.20.0/23"
      availability_zone = "us-east-1b"
    }
  }
}

variable "web_subnet_configs" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = {
    Ventura-Prod-Web-Subnet-1 = {       # Usage for Web agent Servers
      cidr_block        = "10.0.4.0/23" # 507 IPs
      availability_zone = "us-east-1a"
    }
    Ventura-Prod-Web-Subnet-2 = {
      cidr_block        = "10.0.10.0/23"
      availability_zone = "us-east-1b"
    }
  }
}

variable "db_subnet_configs" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = {
    Ventura-Prod-DB-Subnet-1 = {         # Usage for RDS-Mysql DB
      cidr_block        = "10.0.25.0/27" # 27 IPs
      availability_zone = "us-east-1a"
    }
    Ventura-Prod-DB-Subnet-2 = {
      cidr_block        = "10.0.30.0/27"
      availability_zone = "us-east-1b"
    }
  }
}
