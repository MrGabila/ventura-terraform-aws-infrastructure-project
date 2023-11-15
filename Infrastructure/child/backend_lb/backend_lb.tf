#################################  RESOURCES  ######################################################
resource "aws_lb" "backend_lb" {
  name               = "${var.name_prefix}-backend-LB"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnet_ids #web-subnets
  security_groups    = [var.backend_lb_sg_id]
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
  name        = "${var.name_prefix}-backend-HTTP-TG"
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

################################  INPUT VARIABLES  #################################################
variable "name_prefix" {}
variable "vpc_id" {}
variable "subnet_ids" {type = list}
variable "backend_lb_sg_id" {}

###############################  OUTPUT VARIABLES  #################################################
output "backend_TG_arn" {
  value = aws_lb_target_group.backend_lb_tg.arn
}
output "backend_lb_dns_name" {
  value = aws_lb.backend_lb.dns_name
}