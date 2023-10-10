#################### RESOURCES ##########################
resource "aws_security_group" "database_sg" {
  name        = "database-SG"
  description = "Database-Security-Group"

    dynamic "ingress" {
        for_each = var.sg_port_to_source_map
        content {
            from_port   = each.key
            to_port     = each.key
            protocol    = "tcp"
            cidr_blocks = [each.value]
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

#################### INPUT VARIABLES ##########################
variable "sg_port_to_source_map" {
  description = "Map of ports to their respective sources"
  type        = map(any)
  default     = {}
}

#################### OUTPUT VARIABLES ##########################
output "database_sg_id" {
  value = aws_security_group.database_sg.id
}



# resource "aws_db_subnet_group" "db-sub-grp" {
#   name       = "${var.Name}-subnet-grp"
#   subnet_ids = [aws_subnet.db-Subnets["Ventura-Prod-DB-Subnet-1"].id, aws_subnet.db-Subnets["Ventura-Prod-DB-Subnet-2"].id]

# }

# # Create the RDS-db Server
# resource "aws_db_instance" "ventura-RDS" {
#   allocated_storage    = 500
#   storage_type         = "gp2"
#   db_name              = "${var.Name}-RDS"
#   engine               = "mysql"
#   engine_version       = "5.7"
#   instance_class       = "db.m5.large"
#   username             = "admin"
#   password             = "admin"
#   parameter_group_name = "default.mysql5.7"
#   skip_final_snapshot  = true
#   multi_az = true #Enable

#   vpc_security_group_ids = [aws_security_group.ventura-sg.id]
#   tags = var.server-tags
# }