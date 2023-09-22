# Create grloup
resource "aws_security_group" "db-SG" {
    name = "${var.Name}-db-SG"
    description = "SG for Ventura RDS Instance"
    vpc_id = aws_vpc.ventura-VPC.id

    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = [var.subnet_configs.Ventura-Prod-App-Subnet-1.cidr_block, var.subnet_configs.Ventura-Prod-App-Subnet-2.cidr_block ]
    }
    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }
}

# Create the RDS-db Server
resource "aws_db_instance" "ventura-RDS" {
  allocated_storage    = 500
  storage_type         = "gp2"
  db_name              = "${var.Name}-RDS"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.m5.large"
  username             = "admin"
  password             = "admin"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  multi_az = true #Enable

  vpc_security_group_ids = [aws_security_group.ventura-sg.id]
  tags = var.server-tags
}