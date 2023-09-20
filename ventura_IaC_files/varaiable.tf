variable "cidr_block" {
    default = "10.0.0.0/16"
    type = string
  
}

variable "instance_tenancy" {
    default = "dedicated"
  
}

variable "aws_subnet" {
    default = "10.0.1.0/28"
  
}

variable "availability_zone" {
    description = "avaialbility zones"
    type = list(string)
    default = [ "us-east-1a", "us-east-1b" ]
  
}

variable "aws_subnet1" {
    default = "10.0.3.0/28"
  
}

variable "aws_subnet2" {
    default = "10.0.4.0/23"
  
}

variable "aws_subnet3" {
    default = "10.0.10.0/23"
  
}

variable "aws_subnet4" {
    default = "10.0.14.0/23"
  
}
variable "aws_subnet5" {
    default = "10.0.20.0/23"
  
}

variable "aws_subnet6" {
    default = "10.0.25.0/27"
  
}

variable "aws_subnet7" {
    default = "10.0.30.0/27"
  
}

