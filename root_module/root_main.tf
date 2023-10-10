#################### INPUT VARIABLES ##########################
variable "name_prefix" {
  description = "A common for major resources"
  default = "Prod"
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
  depends_on  = [module.vpc]
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
  sg_port_to_source_map = {
    80   = module.frontend_lb.frontend_lb_sg_id
    443  = module.frontend_lb.frontend_lb_sg_id
    22   = module.bastion.bastion_sg_id
  }
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
  sg_port_to_source_map = {
    80   = module.backend_lb.backend_lb_sg_id
    443  = module.backend_lb.backend_lb_sg_id
    22   = module.bastion.bastion_sg_id
  }
}

module "database" {
  source            = "../child_modules/database"
  sg_port_to_source_map = {
    3306   = module.appservers.appservers_sg_id
    3306   = module.bastion.bastion_sg_id
  }
}


# output "frontend_alb_dns_name" {
#   value = module.alb.frontend_alb_dns_name
# }

# output "backend_alb_dns_name" {
#   value = module.alb.backend_alb_dns_name
# }
