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
  profile = "default"

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

###################################  MODULES  ######################################################
module "database" {
  source         = "./child/"
  name_prefix    = var.name_prefix #must be lowercase
  database_name  = "mailingApp"    #must be alpha numeric characters only
  instance_class = "db.m5.large"
  instance_tags  = var.instance_tags
  vpc_id         = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids     = data.terraform_remote_state.network.outputs.db_subnet_ids
  sg_id          = data.terraform_remote_state.network.outputs.security_group_ids["database"]
}

###############################  OUTPUT VARIABLES  #################################################
output "database_endpoint" {
  value = module.database.database_endpoint
}

output "database_name" {
  value = module.database.database_name
}
