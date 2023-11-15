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
  count = "${var.server_side_encryption ? 1 : 0}"
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

#################### INPUT VARIABLES ##########################
variable "bucket_name" {
  description = "unique identifier for the s3 bucket, must be lowercase"
  type = string
}
variable "region" {}
variable "server_side_encryption" {type = bool}
variable "versioning_status" {default = "Disabled"}
variable "block_public_access" {default = true}

#################### OUTPUT VARIABLES ##########################
output "bucket_id" {
  value = aws_s3_bucket.example.id
}