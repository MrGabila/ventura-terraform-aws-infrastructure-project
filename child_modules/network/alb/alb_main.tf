#################### RESOURCES ##########################
resource "aws_lb" "frontend" {
  name               = "tier-2-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnet_ids_frontend

  enable_http2 = true
}

resource "aws_lb" "backend" {
  name               = "tier-3-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnet_ids_backend

  enable_http2 = true
}

#################### INPUT VARIABLES ##########################
variable "subnet_ids_frontend" {}
variable "subnet_ids_backend" {}

#################### OUTPUT VARIABLES ##########################
output "frontend_alb_dns_name" {
  value = aws_lb.frontend.dns_name
}

output "backend_alb_dns_name" {
  value = aws_lb.backend.dns_name
}