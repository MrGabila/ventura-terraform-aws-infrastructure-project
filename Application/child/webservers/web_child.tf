#################### RESOURCES ##########################
# Define Your Launch Configuration for the autoscaling group
resource "aws_launch_configuration" "template" {
  name_prefix                 = "${var.name_prefix}-web-LC"
  image_id                    = var.AMI
  instance_type               = var.instance_type
  key_name                    = var.key_name
  security_groups             = [var.sg_id]
  user_data = var.user_data
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
variable "vpc_id" {}
variable "sg_id" {}
variable "name_prefix" {}
variable "AMI" {}
variable "subnet_ids" {type = list}
variable "key_name" {}
variable "instance_type" {default = "t2.micro"}
variable "tags" {}
variable "desired_capacity" {}
variable "target_group_arns" {type = list}
variable "iam_instance_profile" {}
variable "user_data" {}
#################### OUTPUT VARIABLES ##########################
