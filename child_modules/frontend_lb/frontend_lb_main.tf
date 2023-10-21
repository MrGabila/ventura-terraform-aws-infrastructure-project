#################### RESOURCES ##########################
resource "aws_security_group" "frontend_lb_sg" {
  name        = "frontend-LB-SG"
  description = "Frontend-LB-Security-Group"
  vpc_id = var.vpc_id

    dynamic "ingress" {
        for_each = var.sg_port_to_source_map
        content {
            from_port   = ingress.key
            to_port     = ingress.key
            protocol    = "tcp"
            cidr_blocks = [ingress.value]
            }
    }
}

resource "aws_lb" "frontend_lb" {
  name               = "${var.name_prefix}-frontend-LB"
  internal           = false
  load_balancer_type = "application"
  subnets            = [var.subnet_ids[0],var.subnet_ids[1]] #nat-alb-subnets
  security_groups    = [aws_security_group.frontend_lb_sg.id]
}

resource "aws_lb_listener" "frontend_lb_listener" {
  load_balancer_arn = aws_lb.frontend_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "OK"
    }
  }
}

resource "aws_lb_target_group" "frontend_lb_tg" {
  name        = "Frontend-LB-HTTP-TG"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/VenturaMailingApp.php"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}

#################### INPUT VARIABLES ##########################
variable "name_prefix" {}
variable "vpc_id" {}
variable "sg_port_to_source_map" {
  description = "Map of ports to their respective sources"
  type        = map(any)
  default     = {}
}
variable "subnet_ids" {}

#################### OUTPUT VARIABLES ##########################
output "frontend_lb_sg_id" {
  value = aws_security_group.frontend_lb_sg.id
}

output "frontend_TG_arn" {
  value = aws_lb_target_group.frontend_lb_tg.arn
}

output "frontend_lb_dns_name" {
  value = aws_lb.frontend_lb.dns_name
}

