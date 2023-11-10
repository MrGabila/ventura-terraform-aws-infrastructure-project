#################### RESOURCES ##########################
resource "aws_eip" "EIP" {
  count = 2
  instance = null
}

resource "aws_nat_gateway" "natgw-zone1" {
  allocation_id = aws_eip.EIP[0].id
  subnet_id     = var.subnet_0_id
  tags = {Name = "${var.name_prefix}-NAT-GW-1"}
}

resource "aws_nat_gateway" "natgw-zone2" {
  allocation_id = aws_eip.EIP[1].id
  subnet_id     = var.subnet_1_id
  tags = {Name = "${var.name_prefix}-NAT-GW-2"}
}

#################### INPUT VARIABLES ##########################
variable "name_prefix" {}
variable "subnet_0_id" {}
variable "subnet_1_id" {}

#################### OUTPUT VARIABLES ##########################
output "natgw_zone1_id" {
  value = aws_nat_gateway.natgw-zone1.id
}

output "natgw_zone2_id" {
  value = aws_nat_gateway.natgw-zone2.id
}
