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
data "terraform_remote_state" "infrastructure" {
  backend = "local"
  config = {
    path = "../Infrastructure/terraform.tfstate"
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

variable "nova-key" {
  type      = string
  default   = "Novirginia-region"
  sensitive = true
}

data "aws_iam_instance_profile" "profile" {
  name = "EC2-Role-for-S3"
}
###################################  MODULES  ######################################################
# provision Autoscaling group Instances for the Web tier
module "webservers" {
  source     = "./child/webservers"
  vpc_id         = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids     = data.terraform_remote_state.network.outputs.web_subnet_ids
  sg_id          = data.terraform_remote_state.network.outputs.security_group_ids["webservers"]

  name_prefix          = var.name_prefix
  AMI                  = "ami-0261755bbcb8c4a84"                              # Ubuntu 20.04
  desired_capacity     = 1                                                    # max = 5
  key_name             = var.nova-key
  tags                 = var.instance_tags
  iam_instance_profile = data.aws_iam_instance_profile.profile.name
  target_group_arns    = [data.terraform_remote_state.infrastructure.outputs.frontend_TG_arn]
  user_data            = file("./web-automation.sh")
}
# provision Autoscaling group Instances for the App tier
module "appservers" {
  source     = "./child/appservers"
  vpc_id         = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids     = data.terraform_remote_state.network.outputs.app_subnet_ids
  sg_id          = data.terraform_remote_state.network.outputs.security_group_ids["appservers"]

  name_prefix          = var.name_prefix
  AMI                  = "ami-0bb4c991fa89d4b9b"                              # Amazon Linux 2
  desired_capacity     = 1                                                    # max = 5
  key_name             = var.nova-key
  tags                 = var.instance_tags
  iam_instance_profile = data.aws_iam_instance_profile.profile.name
  target_group_arns    = [data.terraform_remote_state.infrastructure.outputs.backend_TG_arn]
  user_data            = file("./app-automation.sh")
}
###############################  OUTPUT VARIABLES  #################################################
