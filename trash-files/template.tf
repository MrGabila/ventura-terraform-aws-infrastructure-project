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
  #subnet_id = data.terraform_remote_state.network.outputs.web_subnet_ids
  #sg_id = data.terraform_remote_state.network.outputs.security_group_ids["bastion"]

}
###################################  MODULES  ######################################################

###############################  OUTPUT VARIABLES  #################################################







#################################  RESOURCES  ######################################################

################################  INPUT VARIABLES  #################################################

###############################  OUTPUT VARIABLES  #################################################
