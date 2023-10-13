#################### RESOURCES ##########################
resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_acl" "name" {
  bucket = aws_s3_bucket.example.id
  acl = "private"
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

resource "aws_iam_role" "ec2_role" {
  name = "EC2-Role-for-s3"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "name" {
  role = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Upload DB Config files
resource "aws_s3_object" "db_config" {
  for_each = var.local_files
  bucket = aws_s3_bucket.example.id
  key    = each.value
  source = file(each.value)
}

#################### INPUT VARIABLES ##########################
variable "bucket_name" {
  description = "unique identifier for the s3 bucket, must be lowercase"
  type = string
}
variable "region" {}
variable "versioning_status" {default = "Disabled"}
variable "block_public_access" {default = true}
variable "local_files" {type = list}

#################### OUTPUT VARIABLES ##########################
output "bucket_id" {
  value = aws_s3_bucket.example.id
}
output "ec2_role_s3_readonly" {
  value = aws_iam_role.ec2_role.arn
}