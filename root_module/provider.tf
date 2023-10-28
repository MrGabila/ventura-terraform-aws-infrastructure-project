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
##################################################################################################