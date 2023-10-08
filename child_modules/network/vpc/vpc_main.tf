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

#################### INPUT VARIABLES ##########################
variable "cidr_block" {}
variable "name_prefix" {}

#################### OUTPUT VARIABLES ##########################
output "vpc_id" {
  value = aws_vpc.VPC.id
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}