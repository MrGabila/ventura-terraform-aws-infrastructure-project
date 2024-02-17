#################################  RESOURCES  ######################################################
resource "aws_security_group" "bastion_sg" {
  name        = "${var.name_prefix}-bastion-SG"
  description = "Terraform ventura prod bastion-host SG"
  vpc_id = var.vpc_id

  dynamic "ingress" {
    for_each = var.bastion_ports
      content {
          from_port   = ingress.value
          to_port     = ingress.value
          protocol    = "tcp"
          cidr_blocks = [var.user_access_ip]
      }
    }
  egress = var.common_egress
} 

resource "aws_security_group" "frontend_sg" {
  name        = "${var.name_prefix}-frontend-lb-SG"
  description = "Terraform ventura prod frontend SG"
  vpc_id = var.vpc_id
  dynamic "ingress" {
        for_each = var.frontend_lb_ports
        content {
            from_port   = ingress.value
            to_port     = ingress.value
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            }
  }
  egress = var.common_egress
}


resource "aws_security_group" "webservers_sg" {
  name        = "${var.name_prefix}-webservers-SG"
  description = "Terraform ventura prod Web server SG"
  vpc_id = var.vpc_id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    #cidr_blocks = [ "0.0.0.0/0" ]
    security_groups = [aws_security_group.bastion_sg.id]
  }

  dynamic "ingress" {
  for_each = var.webserver_ports
  content {
    from_port   = ingress.value
    to_port     = ingress.value
    protocol    = "tcp"
    #cidr_blocks = [ "0.0.0.0/0" ]
    security_groups = [aws_security_group.frontend_sg.id]
  }
}
  egress = var.common_egress
}

resource "aws_security_group" "backend_sg" {
  name        = "${var.name_prefix}-backend-lb-SG"
  description = "Terraform ventura prod backend SG"
  vpc_id = var.vpc_id
  dynamic "ingress" {
  for_each = var.backend_lb_ports
  content {
    from_port   = ingress.value
    to_port     = ingress.value
    protocol    = "tcp"
    security_groups = [aws_security_group.webservers_sg.id]
    }
  }
  egress = var.common_egress
}

resource "aws_security_group" "appservers_sg" {
  name        = "${var.name_prefix}-appservers-SG"
  description = "Terraform ventura prod App servers SG"
  vpc_id = var.vpc_id
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    #cidr_blocks = [ "0.0.0.0/0" ]
    security_groups = [aws_security_group.bastion_sg.id]
  }

  dynamic "ingress" {
  for_each = var.appserver_ports
  content {
    from_port   = ingress.value
    to_port     = ingress.value
    protocol    = "tcp"
    #cidr_blocks = [ "0.0.0.0/0" ]
    security_groups = [aws_security_group.backend_sg.id]
    }
  }
  egress = var.common_egress
}

resource "aws_security_group" "database_sg" {
  name        = "${var.name_prefix}-database-SG"
  description = "Terraform ventura prod database SG"
  vpc_id = var.vpc_id
  ingress {
    from_port        = var.database_port
    to_port          = var.database_port
    protocol         = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }
  ingress {
    from_port        = var.database_port
    to_port          = var.database_port
    protocol         = "tcp"
    security_groups = [aws_security_group.appservers_sg.id]
  }
    egress = var.common_egress
}

################################  INPUT VARIABLES  #################################################
variable "vpc_id" {}
variable "name_prefix" {}

variable "user_access_ip" {
  description = "The IP address you will use to access the Bastion and the Frontend LB"
  type        = string
  default     = "0.0.0.0/0"
}
variable "bastion_ports" {
  description = "List of Bastion ports that be open to user_access_ip"
  type        = list
  default     = [22]
}
variable "frontend_lb_ports" {
  description = "List of LB ports that be open to the internet"
  type        = list
  default     = [80, 443]
}
variable "webserver_ports" {
  description = "List of ports to connect web servers to frontend_lb, port 22 is open to bastion"
  type        = list
  default     = [80, 443]
}
variable "backend_lb_ports" {
  description = "List of ports to connect backend_lb to Web servers"
  type        = list
  default     = [80, 443]
}
variable "appserver_ports" {
  description = "List of ports to connect App servers to backend_lb, port 22 is open to bastion"
  type        = list
  default     = [80, 443]
}
variable "database_port" {
  description = "DB port to allow incoming request from App servers"
  type        = number
  default     = 3306
}

variable "common_egress" {
  type = set(object({
    description      = string
    security_groups  = list(string)
    prefix_list_ids  = list(string)
    self             = bool
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    ipv6_cidr_blocks = list(string)
  }))

  default = [
    {
      description      = "Allow all outbound traffic"
      security_groups  = []
      prefix_list_ids  = []
      self             = false
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]
}

###############################  OUTPUT VARIABLES  #################################################
output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "frontend_lb_sg_id" {
  value = aws_security_group.frontend_sg.id
}

output "webservers_sg_id" {
  value = aws_security_group.webservers_sg.id
}

output "appservers_sg_id" {
  value = aws_security_group.appservers_sg.id
}

output "backend_lb_sg_id" {
  value = aws_security_group.backend_sg.id
}

output "database_sg_id" {
  value = aws_security_group.database_sg.id
}