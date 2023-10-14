#################### RESOURCES ##########################
resource "aws_security_group" "database_sg" {
  name        = "database-SG"
  description = "Database-Security-Group"
  vpc_id = var.vpc_id

    dynamic "ingress" {
        for_each = var.sg_port_to_source_map
        content {
            from_port   = ingress.key
            to_port     = ingress.key
            protocol    = "tcp"
            security_groups = [ingress.value]
            }
    }
    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_db_subnet_group" "db_subnet_grp" {
  name       = "${var.name_prefix}-db-subnet-grp"
  subnet_ids = var.db_subnet_ids
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
  vpc_security_group_ids = [aws_security_group.database_sg.id]

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
variable "sg_port_to_source_map" {
  description = "Map of ports to their respective sources"
  type        = map(any)
  default     = {}
}
variable "name_prefix" {}
variable "database_name" {}
variable "db_subnet_ids" {}
variable "instance_class" {}
variable "instance_tags" {default = null}
variable "allocated_storage" {default = 30}
variable "storage_type" {default = "gp3"}

#################### OUTPUT VARIABLES ##########################
output "database_sg_id" {
  value = aws_security_group.database_sg.id
}

output "database_endpoint" {
  value = aws_db_instance.database_instance.endpoint
}

output "database_name" {
  value = aws_db_instance.database_instance.db_name
}


# # Create the RDS-db Server
# resource "aws_db_instance" "ventura-RDS" {
#   parameter_group_name = "default.mysql5.7"
# }