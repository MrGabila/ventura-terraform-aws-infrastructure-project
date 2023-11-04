#################### RESOURCES ##########################
resource "aws_db_subnet_group" "db_subnet_grp" {
  name       = "${var.name_prefix}-db-subnet-grp"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "database_instance" {
  #settings
  identifier = "${var.name_prefix}-rds"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = var.instance_class
  username             = "admin"
  password             = "admin12345"

  #storage
  allocated_storage    = var.allocated_storage
  max_allocated_storage = 1000
  storage_type         = var.storage_type
  storage_encrypted = true

  #connectivity
  multi_az                    = true
  db_subnet_group_name = aws_db_subnet_group.db_subnet_grp.name
  vpc_security_group_ids = [var.sg_id]

  #other
  db_name               = var.database_name
  deletion_protection = false
  apply_immediately = true
  skip_final_snapshot         = true
  publicly_accessible         = false
  backup_retention_period     = 7
  backup_window               = "06:00-07:00"
  tags = var.instance_tags
}

#################### INPUT VARIABLES ##########################
variable "vpc_id" {}
variable "sg_id" {}
variable "name_prefix" {description = "must be lowercase"}
variable "database_name" {description = "must be alpha numeric characters only"}
variable "subnet_ids" {}
variable "instance_class" {}
variable "instance_tags" {default = null}
variable "allocated_storage" {default = 30}
variable "storage_type" {default = "gp3"}

#################### OUTPUT VARIABLES ##########################
output "database_endpoint" {
  value = aws_db_instance.database_instance.endpoint
}

output "database_name" {
  value = aws_db_instance.database_instance.db_name
}
