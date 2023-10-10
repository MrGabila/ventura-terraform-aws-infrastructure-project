#################### RESOURCES ##########################
resource "aws_subnet" "subnets" {
  count = length(var.subnet_configs)

  cidr_block        = var.subnet_configs[count.index].cidr_block
  availability_zone = var.subnet_configs[count.index].availability_zone
  vpc_id            = var.vpc_id

  tags = {
    Name = var.subnet_configs[count.index].name
  }
}

#################### INPUT VARIABLES ########################
variable "vpc_id" {}

variable "subnet_configs" {
  description = "List of subnet configurations"
  type        = list(object({
    name             = string
    cidr_block       = string
    availability_zone = string
  }))

  default = [
    {
      name             = "Prod-NAT-ALB-Subnet-1"
      cidr_block       = "10.0.1.0/28" # 11 IPs
      availability_zone = "us-east-1a"
    },
    {
      name             = "Prod-NAT-ALB-Subnet-2"
      cidr_block       = "10.0.3.0/28"
      availability_zone = "us-east-1b"
    },
    {
      name             = "Prod-Web-Subnet-1"
      cidr_block       = "10.0.4.0/23" # 507 IPs
      availability_zone = "us-east-1a"
    },
    {
      name             = "Prod-Web-Subnet-2"
      cidr_block       = "10.0.10.0/23"
      availability_zone = "us-east-1b"
    },
    {
      name             = "Prod-App-Subnet-1"
      cidr_block       = "10.0.14.0/23" # 507 IPs
      availability_zone = "us-east-1a"
    },
    {
      name             = "Prod-App-Subnet-2"
      cidr_block       = "10.0.20.0/23" 
      availability_zone = "us-east-1b"
    },
    {
      name             = "Prod-DB-Subnet-1"
      cidr_block       = "10.0.25.0/27" # 27 IPs
      availability_zone = "us-east-1a"
    },
    {
      name             = "Prod-DB-Subnet-2"
      cidr_block       = "10.0.30.0/27"
      availability_zone = "us-east-1b"
    }
  ]
}

#################### OUTPUT VARIABLES ##########################
output "subnet_ids" {
  value = aws_subnet.subnets[*].id
}

output "subnet_names" {
  value = aws_subnet.subnets[*].tags["Name"]
}