#################### RESOURCES ##########################
resource "aws_security_group" "webservers_sg" {
  name        = "webservers-SG"
  description = "Webservers Security Group"

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

# Define Your Launch Configuration for the autoscaling group
resource "aws_launch_configuration" "template" {
  name_prefix                 = "${var.name_prefix}-web-LC"
  image_id                    = var.AMI
  instance_type               = var.instance_type
  key_name                    = var.key_name
  security_groups             = [aws_security_group.webservers_sg.id]
  user_data                   = "./web-automation.sh"
  associate_public_ip_address = true
  iam_instance_profile = var.iam_instance_profile
}

# Create Auto Scaling Group: specify the desired number of instances, availability zones, and other ASG settings
resource "aws_autoscaling_group" "example" {
  name_prefix               = "${var.name_prefix}-web-ASG"
  launch_configuration      = aws_launch_configuration.template.name
  min_size                  = 1
  max_size                  = 5
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids # web subnets
  health_check_type         = "EC2"
  health_check_grace_period = 300
  target_group_arns         = var.target_group_arns

  dynamic "tag" {
    for_each = var.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
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
variable "subnet_ids" {type = list}
variable "key_name" {}
variable "instance_type" {default = "t2.micro"}
variable "tags" {}
variable "desired_capacity" {}
variable "target_group_arns" {type = list}
variable "iam_instance_profile" {}

#################### OUTPUT VARIABLES ##########################
output "webservers_sg_id" {
  value = aws_security_group.webservers_sg.id
}