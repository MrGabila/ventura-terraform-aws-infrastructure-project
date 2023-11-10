#################### RESOURCES ##########################
resource "aws_route_table" "public" {
  count = 4 # Bastion and Web tier
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }
  tags = {Name = "${replace(var.subnet_names[count.index], "Subnet", "RT")}"}
}

resource "aws_route_table" "private" {
  count         = 4 # App and DB tier
  vpc_id        = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.nat_gateway_ids[count.index % 2]
  }
  tags = {Name = "${replace(var.subnet_names[count.index + 4], "Subnet", "RT")}"}
  
}

# Associate route tables with subnets
resource "aws_route_table_association" "public_subnets" {
  count          = length(aws_route_table.public) # 4 associations
  subnet_id      = var.subnet_ids[count.index % 4]
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_route_table_association" "private_subnets" {
  count          = length(aws_route_table.private) # 4 associations
  subnet_id      = var.subnet_ids[count.index + 4]
  route_table_id = aws_route_table.private[count.index].id
}

#################### INPUT VARIABLES ##########################
variable "name_prefix" {}
variable "vpc_id" {}
variable "internet_gateway_id" {}
variable "nat_gateway_ids" {type = list}
variable "subnet_ids" {type = list}
variable "subnet_names" {type = list}

#################### OUTPUT VARIABLES ##########################
output "public_route_table_ids" {
  value = aws_route_table.public[*].id
}

output "private_route_table_ids" {
  value = aws_route_table.private[*].id
}