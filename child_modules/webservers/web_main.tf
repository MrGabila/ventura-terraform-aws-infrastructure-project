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
resource "aws_launch_configuration" "web-template" {
  name_prefix                 = "${var.name_prefix}-web-"
  image_id                    = data.aws_ami.CentOS7.image_id
  instance_type               = var.instance_type
  key_name                    = var.nova-key
  security_groups             = [aws_security_group.web-SG.id]
  user_data                   = "./web-automation.sh"
  associate_public_ip_address = true
}

# Create Auto Scaling Group: specify the desired number of instances, availability zones, and other ASG settings
resource "aws_autoscaling_group" "example" {
  name_prefix               = "${var.name_prefix}-web-"
  launch_configuration      = aws_launch_configuration.web-template.name
  min_size                  = 1
  max_size                  = var.server-count
  desired_capacity          = var.server-count
  vpc_zone_identifier       = [aws_subnet.Web-Subnets["Ventura-Prod-Web-Subnet-1"].id, aws_subnet.Web-Subnets["Ventura-Prod-Web-Subnet-2"].id] # Specify your subnets
  health_check_type         = "EC2"
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.web-TG.arn]

  dynamic "tag" {
    for_each = var.server-tags

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
variable "subnet_ids" {type = list}

variable "nova-key" {
  type      = string
  default   = "Novirginia-region"
  sensitive = true
}
variable "instance_type" {
  type    = string
  default = "t2.medium"
}

variable "server-count" {
  type    = number
  default = 2
}

variable "server-tags" {
  description = "tags to be added to all instances"
  type        = map(any)
  default = {
    Name = "Ventura-Prod-instance"
    application-id            = "dmt468"
    environment               = "prod"
    budget-code               = "cost-prod"
    region                    = "us-east-1"
    data-classification       = "pii"
    compliance-classification = "nist"
    project-name              = "ventura-project"
  }
}

#################### OUTPUT VARIABLES ##########################
output "webservers_sg_id" {
  value = aws_security_group.webservers_sg.id
}