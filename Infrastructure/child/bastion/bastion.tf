#################################  RESOURCES  ######################################################
# resource "aws_security_group" "bastion_sg" {
#   name        = "${var.name_prefix}-bastion-SG"
#   description = "Bastion Host Security Group"
#   vpc_id = var.vpc_id

#   dynamic "ingress" {
#     for_each = var.sg_port_to_source_map
#     iterator = ingress
#         content {
#             from_port   = ingress.key
#             to_port     = ingress.key
#             protocol    = "tcp"
#             cidr_blocks = [ingress.value]
#         }
#     }
#    egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }
# }

resource "aws_instance" "bastion_host" {
  ami           = var.AMI
  instance_type = var.instance_type
  key_name      = var.key_name
  associate_public_ip_address = true
  subnet_id             = var.subnet_id
  vpc_security_group_ids = [var.bastion_sg_id]
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install mysql-server -y
              sudo hostnamectl set-hostname "ventura-Bastion"
            EOF

  tags = {
    Name = "${var.name_prefix}-Bastion-Host"
  }
}


################################  INPUT VARIABLES  #################################################
# variable "vpc_id" {}
# variable "sg_port_to_source_map" {
#   description = "Map of ports to their respective sources"
#   type        = map(any)
#   default     = {}
# }
variable "bastion_sg_id" {}
variable "name_prefix" {}
variable "AMI" {}
variable "instance_type" {}
variable "key_name" {}
variable "subnet_id" {}

###############################  OUTPUT VARIABLES  #################################################
output "bastion_host_public_ip" {
  value = aws_instance.bastion_host.public_ip
}
