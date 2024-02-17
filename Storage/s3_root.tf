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

data "terraform_remote_state" "infrastructure" {
  backend = "local"
  config = {
    path = "../Infrastructure/terraform.tfstate"
  }
}

data "terraform_remote_state" "database" {
  backend = "local"
  config = {
    path = "../Database/terraform.tfstate"
  }
}

###################################  MODULES  ######################################################
module "s3" {
  source = "./child"

  bucket_name            = "${var.name_prefix}-bucket-use1-2023"
  region                 = "us-east-1"
  versioning_status      = "Enabled"
  block_public_access    = true
  server_side_encryption = true
  source_code =  file("./VenturaMailingApp.php")

  db_endpoint         = data.terraform_remote_state.database.outputs.database_endpoint
  initial_database    = data.terraform_remote_state.database.outputs.database_name
  backend_lb_dns_name = data.terraform_remote_state.infrastructure.outputs.backend_lb_dns_name
}

###############################  OUTPUT VARIABLES  #################################################
output "bucket_id" {
  value = module.s3.bucket_id
}
