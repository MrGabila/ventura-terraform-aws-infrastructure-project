#################### INPUT VARIABLES ##########################
variable "name_prefix" {
  description = "name prefix for major resources"
  default     = "ventura-prod"
}
variable "instance_tags" {
  description = "tags to be added to all instances"
  type        = map(any)
  default = {
    
    application-id            = "dmt468"
    Environment               = "prod"
    budget-code               = "cost-prod"
    region                    = "us-east-1"
    data-classification       = "pii"
    compliance-classification = "nist"
    project-name              = "ventura-project"
  }
}
variable "nova-key" {
  type      = string
  default   = "Novirginia-region"
  sensitive = true
}

data "aws_iam_instance_profile" "profile" {
  name = "EC2-Role-for-S3"
}

#################### RESOURCE MODULES ##########################
module "vpc" { #Creates VPC, IGW and 8 subnets in 2 AZs(4 tier architecture)
  source      = "../child_modules/network/vpc"
  name_prefix = var.name_prefix
  cidr_block  = "10.0.0.0/16"
}

module "nat" { #Creates 2 NATGW in each public subnet
  source      = "../child_modules/network/nat"
  name_prefix = var.name_prefix
  subnet_0_id = element(module.vpc.subnet_ids, 0) # Choose the 1st public subnet
  subnet_1_id = element(module.vpc.subnet_ids, 1) # Choose the 2nd public subnet
  depends_on  = [module.vpc]
}

module "route-tables" { #Creates 8 RTs and associates them with their subnets
  source              = "../child_modules/network/route-tables"
  name_prefix         = var.name_prefix
  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.vpc.igw_id
  nat_gateway_ids     = [module.nat.natgw_zone1_id, module.nat.natgw_zone2_id]
  subnet_ids          = module.vpc.subnet_ids
  subnet_names        = module.vpc.subnet_names

  depends_on = [module.nat]
}

module "bastion" { #Creates a host server in the public subnet
  source = "../child_modules/bastion"
  vpc_id = module.vpc.vpc_id
  sg_port_to_source_map = {
    22 = "0.0.0.0/0"
  }
  name_prefix   = var.name_prefix
  key_name      = var.nova-key
  AMI           = "ami-0261755bbcb8c4a84" # Ubuntu 20.04
  instance_type = "t2.micro"
  subnet_id     = module.vpc.subnet_ids[0] #nat-alb-subnet-1
}

module "frontend_lb" {
  source = "../child_modules/frontend_lb"
  vpc_id = module.vpc.vpc_id
  sg_port_to_source_map = {
    80  = "0.0.0.0/0"
    443 = "0.0.0.0/0"
  }
  subnet_ids  = module.vpc.subnet_ids
  name_prefix = var.name_prefix
}

module "backend_lb" {
  source = "../child_modules/backend_lb"
  vpc_id      = module.vpc.vpc_id
  sg_id       = module.sec_groups.backend_lb_sg_id
  subnet_ids  = module.vpc.subnet_ids
  name_prefix = var.name_prefix
}

module "sec_groups" {
  source            = "../child_modules/network/sec_groups"
  name_prefix       = var.name_prefix
  vpc_id            = module.vpc.vpc_id
  bastion_sg_id     = module.bastion.bastion_sg_id
  frontend_lb_sg_id = module.frontend_lb.frontend_lb_sg_id

  webserver_ports  = [80, 443]
  backend_lb_ports = [80, 433]
  appserver_ports  = [80, 433]
}

module "webservers" {
  source     = "../child_modules/webservers"
  depends_on = [module.s3]
  vpc_id     = module.vpc.vpc_id
  sg_id      = module.sec_groups.webservers_sg_id

  name_prefix          = var.name_prefix
  AMI                  = "ami-0261755bbcb8c4a84"                              # Ubuntu 20.04
  subnet_ids           = [module.vpc.subnet_ids[2], module.vpc.subnet_ids[3]] # web subnets
  desired_capacity     = 2                                                    # max = 5
  key_name             = var.nova-key
  tags                 = var.instance_tags
  iam_instance_profile = data.aws_iam_instance_profile.profile.name
  target_group_arns    = [module.frontend_lb.frontend_TG_arn]
  user_data = file("./web-automation.sh")
}

module "appservers" {
  source     = "../child_modules/appservers"
  depends_on = [module.s3]
  vpc_id     = module.vpc.vpc_id
  sg_id      = module.sec_groups.appservers_sg_id

  name_prefix          = var.name_prefix
  AMI                  = "ami-0bb4c991fa89d4b9b"                              # Amazon Linux 2
  subnet_ids           = [module.vpc.subnet_ids[4], module.vpc.subnet_ids[5]] # app subnets
  desired_capacity     = 2                                                    # max = 5
  key_name             = var.nova-key
  tags                 = var.instance_tags
  iam_instance_profile = data.aws_iam_instance_profile.profile.name
  target_group_arns    = [module.backend_lb.backend_TG_arn]
  user_data = file("./app-automation.sh")
}


module "database" {
  source        = "../child_modules/database"
  vpc_id        = module.vpc.vpc_id
  name_prefix   = var.name_prefix #must be lowercase
  database_name = "mailingApp"    #must be alpha numeric characters only
  sg_port_to_source_map = {
    3306 = module.sec_groups.appservers_sg_id
    3306 = module.bastion.bastion_sg_id
  }
  db_subnet_ids  = [module.vpc.subnet_ids[6], module.vpc.subnet_ids[7]]
  instance_class = "db.m5.large"
  instance_tags  = var.instance_tags
}

module "s3" {
  source     = "../child_modules/s3"
  depends_on = [module.database]

  bucket_name         = "${var.name_prefix}-bucket-use1-2023"
  region              = "us-east-1"
  versioning_status   = "Enabled"
  block_public_access = true
  server_side_encryption = true

  db_endpoint         = module.database.database_endpoint
  initial_database    = module.database.database_name
  backend_lb_dns_name = module.backend_lb.backend_lb_dns_name
}

output "frontend_lb_dns_name" {
  value = module.frontend_lb.frontend_lb_dns_name
}

output "backend_lb_dns_name" {
  value = module.backend_lb.backend_lb_dns_name
}

# module "route53" {
#   source               = "../child_modules/route53"
#   depends_on           = [module.frontend_lb]
#   hosted_zone          = "gabinator.link"
#   domain_name          = "gabinator.link"
#   frontend_lb_dns_name = module.frontend_lb.frontend_lb_dns_name
#   my_email             = "nyuykimo@gmail.com" #NOTE: ACCEPT THE SNS EMAIL SUBSCRIPTION REQUEST THAT WILL BE SENT TO YOUR EMAIL
# }
