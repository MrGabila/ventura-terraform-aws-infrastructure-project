#################### RESOURCES ##########################
resource "local_file" "dbinfo" {
  content  = <<-EOF
    <?php

    define('DB_SERVER', '${var.db_endpoint}');
    define('DB_USERNAME', 'admin');
    define('DB_PASSWORD', 'adminadmin');
    define('DB_DATABASE', '${var.initial_database}');

    ?>
  EOF
  filename = "./dbinfo.inc"
}

resource "local_file" "default-conf" {
  content  = <<-EOF
<VirtualHost *:80>

    ProxyPass / http://${var.backend_lb_dns_name}/VenturaMailingApp.php/

</VirtualHost>
  EOF
  filename = "./000-default.conf"
}

# # Uploading DB Config files to s3 bucket
resource "aws_s3_object" "example" {
  bucket = aws_s3_bucket.example.id
  key    = "VenturaMailingApp.php"
  content = var.source_code
}

resource "aws_s3_object" "default-conf" {
  bucket = aws_s3_bucket.example.id
  key    = "000-default.conf"
  content = local_file.default-conf.content
}

resource "aws_s3_object" "dbinfo" {
  bucket = aws_s3_bucket.example.id
  key    = "dbinfo.inc"
  content = local_file.dbinfo.content
}

#################### INPUT VARIABLES ##########################
variable "db_endpoint" {}
variable "initial_database" {}
variable "backend_lb_dns_name" {}
variable "source_code" {}

#################### OUTPUT VARIABLES ##########################
