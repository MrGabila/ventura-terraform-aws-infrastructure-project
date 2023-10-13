#################### INPUT VARIABLES ##########################
variable "name_prefix" {
  description = "name prefix for major resources"
  default = "Ventura-Prod"
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
#################### RESOURCE MODULES ##########################
module "vpc" {
  source     = "../child_modules/network/vpc"
  name_prefix = var.name_prefix
  cidr_block = "10.0.0.0/16"
}

module "subnets" { #Creates 8 subnets in 2 AZs(4 tier architecture)
  source = "../child_modules/network/subnet"
  vpc_id = module.vpc.vpc_id
}

module "nat" {
  source      = "../child_modules/network/nat"
  name_prefix        = var.name_prefix
  subnet_1_id = element(module.subnets.subnet_ids, 0) # Choose the 1st public subnet
  subnet_2_id = element(module.subnets.subnet_ids, 1) # Choose the 2nd public subnet
  depends_on  = [module.subnets]
}

module "route-tables" {
  source              = "../child_modules/network/route-tables"
  name_prefix = var.name_prefix
  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.vpc.igw_id
  nat_gateway_ids     = [module.nat.natgw_zone1_id, module.nat.natgw_zone2_id]
  subnet_ids          = module.subnets.subnet_ids
  subnet_names = module.subnets.subnet_names

  depends_on = [module.vpc, module.nat]
}

module "bastion" {
  source            = "../child_modules/bastion"
  sg_port_to_source_map = {
    22   = "0.0.0.0/0"
  }
  name_prefix = var.name_prefix
  key_name = var.nova-key
  AMI = "ami-0261755bbcb8c4a84" # Ubuntu 20.04
  instance_type = "t2.micro"
  subnet_id = module.subnets.subnet_ids[0] #nat-alb-subnet
}

module "frontend_lb" {
  source            = "../child_modules/frontend_lb"
  sg_port_to_source_map = {
    80   = "0.0.0.0/0"
    443   = "0.0.0.0/0"
  }
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.subnets.subnet_ids
}

module "webservers" {
  source            = "../child_modules/webservers"
  depends_on = [module.frontend_lb, module.s3]
  sg_port_to_source_map = {
    80   = module.frontend_lb.frontend_lb_sg_id
    443  = module.frontend_lb.frontend_lb_sg_id
    22   = module.bastion.bastion_sg_id
  }

  name_prefix = var.name_prefix
  AMI = "ami-0261755bbcb8c4a84" # Ubuntu 20.04
  subnet_ids = [module.subnets.subnet_ids[2], module.subnets.subnet_ids[3]]# web subnets
  desired_capacity = 2 # max = 5
  key_name = var.nova-key
  tags = var.instance_tags
  iam_instance_profile = module.s3.ec2_role_s3_readonly
  target_group_arns = [module.frontend_lb.frontend_TG_arn]
}

module "backend_lb" {
  source            = "../child_modules/backend_lb"
  sg_port_to_source_map = {
    80   = module.webservers.webservers_sg_id
    443  = module.webservers.webservers_sg_id
    22   = module.bastion.bastion_sg_id
  }
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.subnets.subnet_ids
}

module "appservers" {
  source            = "../child_modules/appservers"
  depends_on = [module.backend_lb, module.s3]
  sg_port_to_source_map = {
    80   = module.backend_lb.backend_lb_sg_id
    443  = module.backend_lb.backend_lb_sg_id
    22   = module.bastion.bastion_sg_id
  }

  name_prefix = var.name_prefix
  AMI = "ami-0261755bbcb8c4a84" # Ubuntu 20.04
  subnet_ids = [module.subnets.subnet_ids[4], module.subnets.subnet_ids[5]] # app subnets
  desired_capacity = 2 # max = 5
  key_name = var.nova-key
  tags = var.instance_tags
  iam_instance_profile = module.s3.ec2_role_s3_readonly
  target_group_arns = [module.backend_lb.backend_TG_arn]
}

module "database" {
  source            = "../child_modules/database"
  name_prefix = var.name_prefix
  database_name = "php-app-database"
  sg_port_to_source_map = {
    3306   = module.appservers.appservers_sg_id
    3306   = module.bastion.bastion_sg_id
  }
  db_subnet_ids = [module.subnets.subnet_ids[6], module.subnets.subnet_ids[7]]
  instance_class       = "db.t2.micro" #"db.m5.large"
  instance_tags = var.instance_tags
}

module "local_file" {
  source = "../child_modules/local_file_db-configs"
  depends_on = [module.database, module.backend_lb]
  db_endpoint = module.database.database_endpoint
  initial_database = module.database.database_name
  backend_lb_dns_name = module.backend_lb.backend_lb_dns_name
}
module "s3" {
  source       = "../child_modules/s3"
  depends_on = [module.local_file]

  bucket_name  = "${var.name_prefix}_bucket_use1_2023"
  region = "us-east-1"
  versioning_status = "Enabled"
  block_public_access = true
  local_files = module.local_file.files
}

output "frontend_lb_dns_name" {
  value = module.frontend_lb_dns_name
}

output "backend_lb_dns_name" {
  value = module.backend_lb_dns_name
}

module "route53" {
  source = "../child_modules/route53"
  depends_on = [module.frontend_lb ]
  hosted_zone = "gabinator.link"
  domain_name = "gabinator.link"
  frontend_lb_dns_name = module.frontend_lb.frontend_lb_dns_name
  my_email = "nyuykimo@gmail.com" #NOTE: ACCEPT THE SNS EMAIL SUBSCRIPTION REQUEST THAT WILL BE SENT TO YOUR EMAIL
}
