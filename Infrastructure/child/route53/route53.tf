#################### RESOURCES ##########################
resource "aws_route53_record" "php_webapp_dns_record" {
  zone_id = var.hosted_zone
  name    = var.domain_name
  type    = "CNAME"
  ttl     = "300"
  records = [var.frontend_lb_dns_name] # Prod-Frontend-LB DNS
}

resource "aws_route53_health_check" "prod_webapp_hc" {
  fqdn                        = var.domain_name
  port                        = 80
  type                        = "HTTP"
  resource_path               = "/VenturaMailingApp.php"
  failure_threshold           = 3
  request_interval            = 30
  measure_latency             = true
  invert_healthcheck          = false
  disabled                    = false

  tags = {
    Name = "Prod-Webapp-HC"
  }
}

resource "aws_sns_topic" "php_webapp_sns_topic" {
  name = "PHP-Webapp-SNS-Topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.php_webapp_sns_topic.arn
  protocol  = "email"
  endpoint  = var.my_email
}
#################### INPUT VARIABLES ##########################
variable "domain_name" {}
variable "hosted_zone" {}
variable "my_email" {}
variable "frontend_lb_dns_name" {}

#################### OUTPUT VARIABLES ##########################

