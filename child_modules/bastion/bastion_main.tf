#################### RESOURCES ##########################
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-host-SG"
  description = "Bastion Host Security Group"

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

resource "aws_instance" "bastion_host" {
  ami           = var.AMI
  instance_type = var.instance_type
  key_name      = var.key_name
  associate_public_ip_address = true
  subnet_id             = var.subnet_id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "${var.name_prefix}-Bastion-Host"
  }
}


#################### INPUT VARIABLES ##########################
variable "sg_port_to_source_map" {
  description = "Map of ports to their respective sources"
  type        = map(any)
  default     = {}
}
variable "name_prefix" {}
variable "AMI" {}
variable "instance_type" {}
variable "key_name" {}
variable "subnet_id" {}
#################### OUTPUT VARIABLES ##########################
output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}
output "bastion_host_public_ip" {
  value = aws_instance.bastion_host.public_ip
}
