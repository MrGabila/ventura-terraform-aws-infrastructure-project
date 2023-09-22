# Create the load balancer for the web tier
resource "aws_lb" "web-ALB" {
  name               = "web-load-balancer"
  internal           = false  # Set to true for an internal (VPC) load balancer
  load_balancer_type = "application"
  enable_deletion_protection = false  # Set to true to enable deletion protection
  subnets = [aws_subnet.ALB-Subnets["Ventura-Prod-NAT-ALB-Subnet-1"].id, aws_subnet.ALB-Subnets["Ventura-Prod-ALB-Subnet-2"].id]  # Specify the subnets where the ALB should be deployed
  enable_http2 = true  # Enable HTTP/2 for the ALB
  tags = {
    Name = "${var.Name}-web-ALB"
  }
}

# Define a target group for the ALB
resource "aws_lb_target_group" "web-TG" {
  name        = "ventura-prod-web-TG"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.ventura-VPC.id  # Replace with your VPC ID
  target_type = "instance"
}

# Define an ALB Listener to associate the ASG instances with an ALB, create an ALB listener rule:
resource "aws_lb_listener" "web-listener" {
  load_balancer_arn = aws_lb.web-ALB.arn
  
  default_action {
    target_group_arn = aws_lb_target_group.web-TG.arn
    type             = "forward"
  }
}

# Define Security group for the Web servers
resource "aws_security_group" "web-SG" {
  name        = "ssh-http_SG"
  description = "security group for web Auto scaling Group"
  vpc_id      = aws_vpc.ventura-VPC.id 

  ingress {
    from_port          = 22
    to_port            = 22
    protocol           = "tcp"
    security_groups    = [aws_lb.web-ALB.security_groups]  # load balancer's security group
  }

  ingress {
    from_port          = 80
    to_port            = 80
    protocol           = "tcp"
    security_groups    = [aws_lb.web-ALB.security_groups]
  }
}

# Define Your Launch Configuration for the autoscaling group
resource "aws_launch_configuration" "web-template" {
  name_prefix                 = "${var.Name}-web-"
  image_id                    = data.aws_ami.CentOS7
  instance_type               = var.instance_type
  key_name                    = var.nova-key
  security_groups             = [aws_security_group.web-SG.id]
  user_data                   = "./web-server-userdata.sh"
  associate_public_ip_address = true
}

# Create Auto Scaling Group: specify the desired number of instances, availability zones, and other ASG settings
resource "aws_autoscaling_group" "example" {
  name_prefix                 = "${var.Name}-web-"
  launch_configuration        = aws_launch_configuration.web-template.name
  min_size                    = 2
  max_size                    = var.server-count
  desired_capacity            = var.server-count
  vpc_zone_identifier          = [aws_subnet.Web-Subnets["Ventura-Prod-Web-Subnet-1"].id, aws_subnet.Web-Subnets["Ventura-Prod-Web-Subnet-2"].id] # Specify your subnets
  health_check_type           = "EC2"
  health_check_grace_period   = 300
  target_group_arns           = [aws_lb_target_group.web-TG.arn]
  tag {
    tags = var.server-tags
  }
}
