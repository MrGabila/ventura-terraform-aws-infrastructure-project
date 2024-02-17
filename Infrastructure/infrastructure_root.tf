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

data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../Network/terraform.tfstate"
  }
}

variable "nova-key" {
  type      = string
  default   = "Novirginia-region"
  sensitive = true
}

###################################  MODULES  ######################################################
module "bastion" { #Creates a host server in the public subnet
  source        = "./child/bastion"
  name_prefix   = var.name_prefix
  key_name      = var.nova-key
  AMI           = "ami-0261755bbcb8c4a84" # Ubuntu 20.04
  instance_type = "t2.micro"
  subnet_id     = data.terraform_remote_state.network.outputs.nat_lb_subnet_ids[0]
  bastion_sg_id = data.terraform_remote_state.network.outputs.security_group_ids["bastion"]
  # Note: to login via bastion ssh into the Web and App servers, use the private IP address
}

module "frontend_lb" {
  source            = "./child/frontend_lb"
  name_prefix       = var.name_prefix
  vpc_id            = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids        = data.terraform_remote_state.network.outputs.nat_lb_subnet_ids
  frontend_lb_sg_id = data.terraform_remote_state.network.outputs.security_group_ids["frontend"]
}

module "backend_lb" {
  source           = "./child/backend_lb"
  name_prefix      = var.name_prefix
  vpc_id           = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids       = data.terraform_remote_state.network.outputs.web_subnet_ids
  backend_lb_sg_id = data.terraform_remote_state.network.outputs.security_group_ids["backend"]
}

# module "route53" {
#   source               = "./child/route53"
#   depends_on           = [module.frontend_lb]
#   hosted_zone          = "gabinator.link"
#   domain_name          = "gabinator.link"
#   frontend_lb_dns_name = module.frontend_lb.frontend_lb_dns_name
#   my_email             = "nyuykimo@gmail.com" #NOTE: ACCEPT THE SNS EMAIL SUBSCRIPTION REQUEST THAT WILL BE SENT TO YOUR EMAIL
# }

###############################  OUTPUT VARIABLES  #################################################
output "bastion_public_ip" {
  value = module.bastion.bastion_host_public_ip
}

output "frontend_lb_dns_name" {
  value = module.frontend_lb.frontend_lb_dns_name
}
output "frontend_TG_arn" {
  value = module.frontend_lb.frontend_TG_arn
}

output "backend_lb_dns_name" {
  value = module.backend_lb.backend_lb_dns_name
}
output "backend_TG_arn" {
  value = module.backend_lb.backend_TG_arn
}