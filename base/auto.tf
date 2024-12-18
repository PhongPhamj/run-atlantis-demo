locals {
  config = yamldecode(file("./resources/demos3creation.yaml"))
}

resource "aws_s3_bucket" "this" {
  bucket              = local.config.bucket
  force_destroy       = local.config
  object_lock_enabled = local.config.object_lock_enabled
  tags                = merge(local.config.tags, {})

  lifecycle {
    ignore_changes = [
      local.config.tags
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
  acl        = local.config.acl
  depends_on = [aws_s3_bucket_public_access_block.this, aws_s3_bucket_ownership_controls.this]
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = try(lower(local.config.acl), null) == "private" ? true : false
  block_public_policy     = try(lower(local.config.acl), null) == "private" ? true : false
  ignore_public_acls      = try(lower(local.config.acl), null) == "private" ? true : false
  restrict_public_buckets = try(lower(local.config.acl), null) == "private" ? true : false
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = local.config.enable_versioning ? "Enabled" : "Suspended"
  }
}
