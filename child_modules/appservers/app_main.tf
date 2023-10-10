#################### RESOURCES ##########################
resource "aws_security_group" "appservers_sg" {
  name        = "appservers-SG"
  description = "Appservers Security Group"

  dynamic "ingress" {
  for_each = var.sg_port_to_source_map
  content {
    from_port   = each.key
    to_port     = each.key
    protocol    = "tcp"
    security_groups = [each.value]
    }
}

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

#################### INPUT VARIABLES ##########################
variable "sg_port_to_source_map" {
  description = "Map of ports to their respective sources"
  type        = map(any)
  default     = {}
}

#################### OUTPUT VARIABLES ##########################
output "appservers_sg_id" {
  value = aws_security_group.appservers_sg.id
}

