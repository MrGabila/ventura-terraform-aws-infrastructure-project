#################### RESOURCES ##########################
resource "local_file" "dbinfo" {
  content  = <<-EOT
    <?php

    define('DB_SERVER', '${var.db_endpoint}');
    define('DB_USERNAME', 'admin');
    define('DB_PASSWORD', 'admin12345');
    define('DB_DATABASE', '${var.initial_database}');

    ?>
  EOT
  filename = "./dbinfo.inc"
}

resource "local_file" "default-conf" {
  content  = <<-EOT
<VirtualHost *:80>

    ProxyPass / http://${var.backend_lb_dns_name}/VenturaMailingApp.php/

</VirtualHost>
  EOT
  filename = "./000-default.conf"
}

data "local_file" "php-file" {
  filename = "./VenturaMailingApp.php"
}

#################### INPUT VARIABLES ##########################
variable "db_endpoint" {}
variable "initial_database" {}
variable "backend_lb_dns_name" {}
#################### OUTPUT VARIABLES ##########################
output "files" {
  value = [local_file.dbinfo.filename, local_file.default-conf.filename, data.local_file.php-file.filename]
}
