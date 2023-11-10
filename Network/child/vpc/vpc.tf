#################### RESOURCES ##########################
resource "aws_vpc" "VPC" {
  cidr_block = var.cidr_block
  tags = {
    Name = "${var.name_prefix}-VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    Name = "${var.name_prefix}-IGW"
  }
}

resource "aws_subnet" "subnets" {
  count = length(var.subnet_configs)

  cidr_block        = var.subnet_configs[count.index].cidr_block
  availability_zone = var.subnet_configs[count.index].availability_zone
  vpc_id            = aws_vpc.VPC.id

  tags = {
    Name = var.subnet_configs[count.index].name
  }
}
#################### INPUT VARIABLES ##########################
variable "cidr_block" {}
variable "name_prefix" {}

variable "subnet_configs" {
  description = "List of subnet configurations"
  type        = list(object({
    name             = string
    cidr_block       = string
    availability_zone = string
  }))
}

#################### OUTPUT VARIABLES ##########################
output "vpc_id" {
  value = aws_vpc.VPC.id
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "subnet_ids" {
  value = aws_subnet.subnets[*].id
}

output "subnet_names" {
  value = aws_subnet.subnets[*].tags["Name"]
}