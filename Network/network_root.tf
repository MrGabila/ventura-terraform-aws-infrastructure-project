#################################  PROVIDERS  ######################################################
terraform {
  required_version = ">= 1.3.8" #--for terraform
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.22.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "Dzeko"

  default_tags {
    tags = {
      Test = "test"
    }
  }
}
################################  INPUT VARIABLES  #################################################
variable "name_prefix" {
  description = "name prefix for major resources"
  default     = "ventura-prod"
}

locals {
  subnet_configs = [
    {
      name              = "Prod-NAT-ALB-Subnet-1"
      cidr_block        = "10.0.1.0/28" # 11 IPs
      availability_zone = "us-east-1a"
    },
    {
      name              = "Prod-NAT-ALB-Subnet-2"
      cidr_block        = "10.0.3.0/28"
      availability_zone = "us-east-1b"
    },
    {
      name              = "Prod-Web-Subnet-1"
      cidr_block        = "10.0.4.0/23" # 507 IPs
      availability_zone = "us-east-1a"
    },
    {
      name              = "Prod-Web-Subnet-2"
      cidr_block        = "10.0.10.0/23"
      availability_zone = "us-east-1b"
    },
    {
      name              = "Prod-App-Subnet-1"
      cidr_block        = "10.0.14.0/23" # 507 IPs
      availability_zone = "us-east-1a"
    },
    {
      name              = "Prod-App-Subnet-2"
      cidr_block        = "10.0.20.0/23"
      availability_zone = "us-east-1b"
    },
    {
      name              = "Prod-DB-Subnet-1"
      cidr_block        = "10.0.25.0/27" # 27 IPs
      availability_zone = "us-east-1a"
    },
    {
      name              = "Prod-DB-Subnet-2"
      cidr_block        = "10.0.30.0/27"
      availability_zone = "us-east-1b"
    }
  ]
}

###################################  MODULES  ######################################################
module "vpc" { #Creates VPC, IGW and 8 subnets in 2 AZs(4 tier architecture)
  source         = "./child/vpc"
  name_prefix    = var.name_prefix
  cidr_block     = "10.0.0.0/16"
  subnet_configs = local.subnet_configs
}

module "nat" { #Creates 2 NATGW in each public subnet
  source      = "./child/nat"
  name_prefix = var.name_prefix
  subnet_0_id = element(module.vpc.subnet_ids, 0) # Choose the 1st public subnet
  subnet_1_id = element(module.vpc.subnet_ids, 1) # Choose the 2nd public subnet
  depends_on  = [module.vpc]
}

module "route-tables" { #Creates 8 RTs and associates them with each subnet
  source              = "./child/route_tables"
  name_prefix         = var.name_prefix
  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.vpc.igw_id
  nat_gateway_ids     = [module.nat.natgw_zone1_id, module.nat.natgw_zone2_id]
  subnet_ids          = module.vpc.subnet_ids
  subnet_names        = module.vpc.subnet_names

  depends_on = [module.nat]
}

module "sec_groups" {
  source             = "./child/sec_groups"
  name_prefix        = var.name_prefix
  vpc_id             = module.vpc.vpc_id
  user_access_ip = "0.0.0.0/0"

  bastion_ports     = [22]
  frontend_lb_ports = [80, 443]
  webserver_ports   = [80, 443] #port 22 is already open to bastion
  backend_lb_ports  = [80, 443]
  appserver_ports   = [80, 443] #port 22 is already open to bastion
  database_port     = 3306
}

###############################  OUTPUT VARIABLES  #################################################
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "nat_lb_subnet_ids" {
  value = [module.vpc.subnet_ids[0], module.vpc.subnet_ids[1]]
}
output "web_subnet_ids" {
  value = [module.vpc.subnet_ids[2], module.vpc.subnet_ids[3]]
}
output "app_subnet_ids" {
  value = [module.vpc.subnet_ids[4], module.vpc.subnet_ids[5]]
}
output "db_subnet_ids" {
  value = [module.vpc.subnet_ids[6], module.vpc.subnet_ids[7]]
}

output "security_group_ids" {
  value = {
    bastion    = module.sec_groups.bastion_sg_id,
    frontend   = module.sec_groups.frontend_lb_sg_id,
    webservers = module.sec_groups.webservers_sg_id,
    backend    = module.sec_groups.backend_lb_sg_id,
    appservers = module.sec_groups.appservers_sg_id,
    database   = module.sec_groups.database_sg_id
  }
}


