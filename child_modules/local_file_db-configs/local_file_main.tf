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

# data "local_file" "php-file" {
#   filename = "~/OneDrive/Desktop/DevOps/Repositories/ventura_Prod-Env_infrastructure_project/child_modules/local_file_db-configs/VenturaMailingApp.php"
# }

#################### INPUT VARIABLES ##########################
variable "db_endpoint" {}
variable "initial_database" {}
variable "backend_lb_dns_name" {}

#################### OUTPUT VARIABLES ##########################
output "upload_to_s3" {
  value = {
    "dbinfo.inc"      = local_file.dbinfo.content
    "000-default.conf" = local_file.default-conf.content
   # "VenturaMailingApp.php"     = data.local_file.php-file.content
  }
}
