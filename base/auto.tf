locals {
  tags = merge(var.tags, {})
}

resource "aws_s3_bucket" "this" {
  bucket              = var.bucket
  force_destroy       = var.force_destroy
  object_lock_enabled = var.object_lock_enabled
  tags                = merge(var.tags, {})

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_acl" "this" {
  bucket     = aws_s3_bucket.this.id
  acl        = var.acl
  depends_on = [aws_s3_bucket_public_access_block.this, aws_s3_bucket_ownership_controls.this]
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = try(lower(var.acl), null) == "private" ? true : false
  block_public_policy     = try(lower(var.acl), null) == "private" ? true : false
  ignore_public_acls      = try(lower(var.acl), null) == "private" ? true : false
  restrict_public_buckets = try(lower(var.acl), null) == "private" ? true : false
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# bucket = "phongvupham-unique-name-161618122024"

# acl = "private"

# force_destroy = true

# object_lock_enabled = false

# enable_versioning = true

# tags = {
#   Environment = "dev"
#   Project     = "MyS3BucketProject"
# }

