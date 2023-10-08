## S3 Module arguments
# 1. bucket_name(string)
# 2. version_state(number)
# 3. block_public_access(bool)

resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name
  tags = {
    Name        = "terraform-bucket"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    #status = "${var.versioning == 2 ? "Enabled" : (var.versioning == 1 ? "Suspended" : (var.versioning == 0 ? "Disabled" : "Disabled"))}"
    status = var.versioning[var.version_state]
  }
}

resource "aws_s3_bucket_public_access_block" "bpa_example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = var.block_public_access # Reject PUT Bucket acl and PUT Object acl calls
  block_public_policy     = var.block_public_access # Reject calls to PUT Bucket policy
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access
}