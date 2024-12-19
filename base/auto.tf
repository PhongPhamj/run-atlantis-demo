locals {
  yaml_files = fileset("./resources", "*.yaml")

  config = merge([
    for file_path in local.yaml_files : yamldecode(file((join("", ["./resources/", file_path]))))
  ]...)
}

resource "aws_s3_bucket" "this" {
  count               = length(local.config)
  bucket              = local.config[count.index].bucket
  force_destroy       = local.config[count.index].force_destroy
  object_lock_enabled = local.config[count.index].object_lock_enabled
  tags                = merge(local.config[count.index].tags, {})

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  count  = length(local.config)
  bucket = aws_s3_bucket.this[count.index].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_acl" "this" {
  count      = length(local.config)
  bucket     = aws_s3_bucket.this[count.index].id
  acl        = local.config[count.index].acl
  depends_on = [aws_s3_bucket_public_access_block.this, aws_s3_bucket_ownership_controls.this]
}

resource "aws_s3_bucket_public_access_block" "this" {
  count                   = length(local.config)
  bucket                  = aws_s3_bucket.this[count.index].id
  block_public_acls       = try(lower(local.config[count.index].acl), null) == "private" ? true : false
  block_public_policy     = try(lower(local.config[count.index].acl), null) == "private" ? true : false
  ignore_public_acls      = try(lower(local.config[count.index].acl), null) == "private" ? true : false
  restrict_public_buckets = try(lower(local.config[count.index].acl), null) == "private" ? true : false
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.this[count.index].id
  versioning_configuration {
    status = local.config[count.index].enable_versioning ? "Enabled" : "Suspended"
  }
}
