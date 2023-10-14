#################### RESOURCES ##########################
resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = var.versioning_status
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse-example" {
  bucket = aws_s3_bucket.example.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "bpa_example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = var.block_public_access 
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}

# Upload DB Config files
resource "aws_s3_object" "db_config" {
  for_each = var.local_files
  bucket = aws_s3_bucket.example.id
  key    = each.key
  content = each.value
}
#ventura-prod_bucket_use1_2023
resource "null_resource" "upload_to_s3" {
  provisioner "local-exec" {
    command = "aws s3 cp ../child_modules/local_file_db-configs/VenturaMailingApp.php s3://${var.bucket_name}/VenturaMailingApp.php"
  }

  depends_on = [aws_s3_bucket.example] # Make sure the S3 bucket is created first
}

#################### INPUT VARIABLES ##########################
variable "bucket_name" {
  description = "unique identifier for the s3 bucket, must be lowercase"
  type = string
}
variable "region" {}
variable "versioning_status" {default = "Disabled"}
variable "block_public_access" {default = true}
variable "local_files" {type = map}

#################### OUTPUT VARIABLES ##########################
output "bucket_id" {
  value = aws_s3_bucket.example.id
}