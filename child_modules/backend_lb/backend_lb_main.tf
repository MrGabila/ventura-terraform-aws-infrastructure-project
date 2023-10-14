#################### RESOURCES ##########################
resource "aws_security_group" "backend_lb_sg" {
  name        = "backend-LB-SG"
  description = "Backend-LB-Security-Group"
  vpc_id = var.vpc_id

  dynamic "ingress" {
  for_each = var.sg_port_to_source_map
  content {
    from_port   = ingress.key
    to_port     = ingress.key
    protocol    = "tcp"
    security_groups = [ingress.value]
    }
}
}

resource "aws_lb" "backend_lb" {
  name               = "${var.name_prefix}-backend-LB"
  internal           = false
  load_balancer_type = "application"
  subnets            = [var.subnet_ids[2], var.subnet_ids[3]] #web-subnets
  security_groups    = [aws_security_group.backend_lb_sg.id]
}

resource "aws_lb_listener" "backend_lb_listener" {
  load_balancer_arn = aws_lb.backend_lb.arn
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

resource "aws_lb_target_group" "backend_lb_tg" {
  name        = "Backend-LB-HTTP-TG"
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
  type        = map(any)
  default     = {}
}
variable "subnet_ids" {}

#################### OUTPUT VARIABLES ##########################
output "backend_lb_sg_id" {
  value = aws_security_group.backend_lb_sg.id
}
output "backend_TG_arn" {
  value = aws_lb_target_group.backend_lb_tg.arn
}
output "backend_lb_dns_name" {
  value = aws_lb.backend_lb.dns_name
}