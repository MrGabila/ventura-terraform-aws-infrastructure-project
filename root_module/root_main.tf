#################### INPUT VARIABLES ##########################


#################### RESOURCE MODULES ##########################
module "vpc" {
  source     = "../child_modules/network/vpc"
  name_prefix = "Prod"
  cidr_block = "10.0.0.0/16"
}

module "subnets" { #Creates 8 subnets in 2 AZs(4 tier architecture)
  source = "../child_modules/network/subnet"
  vpc_id = module.vpc.vpc_id
}

module "nat" {
  source      = "../child_modules/network/nat"
  name_prefix        = "Prod"
  subnet_1_id = element(module.subnets.subnet_ids, 0) # Choose the 1st public subnet
  subnet_2_id = element(module.subnets.subnet_ids, 1) # Choose the 2nd public subnet
  depends_on  = [module.vpc]
}

module "route-tables" {
  source              = "../child_modules/network/route-tables"
  name_prefix = "Prod"
  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.vpc.igw_id
  nat_gateway_ids     = [module.nat.natgw_zone1_id, module.nat.natgw_zone2_id]
  subnet_ids          = module.subnets.subnet_ids
  subnet_names = module.subnets.subnet_names

  depends_on = [module.vpc, module.nat]
}

# module "alb" {
#   source = "../child_modules/network/alb"
#   subnet_ids_frontend = [element(module.subnets.private_subnet_ids, 0), element(module.subnets.private_subnet_ids, 1)]
#   subnet_ids_backend = [element(module.subnets.private_subnet_ids, 2), element(module.subnets.private_subnet_ids, 3)]
# }
# output "frontend_alb_dns_name" {
#   value = module.alb.frontend_alb_dns_name
# }

# output "backend_alb_dns_name" {
#   value = module.alb.backend_alb_dns_name
# }
