locals {
  yaml_files = fileset("./resources", "*.yaml")
  
  configs = {
    for file_path in local.yaml_files :
    file_path => yamldecode(file(join("", ["./resources/", file_path])))
  }
}

resource "aws_s3_bucket" "this" {
  for_each            = local.configs
  bucket              = each.value.bucket
  force_destroy       = each.value.force_destroy
  object_lock_enabled = each.value.object_lock_enabled
  tags                = merge(each.value.tags, {})

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  for_each = local.configs
  bucket   = aws_s3_bucket.this[each.key].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "this" {
  for_each   = local.configs
  bucket     = aws_s3_bucket.this[each.key].id
  acl        = each.value.acl
  depends_on = [
    aws_s3_bucket_public_access_block.this,
    aws_s3_bucket_ownership_controls.this,
  ]
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = local.configs
  bucket   = aws_s3_bucket.this[each.key].id

  block_public_acls      = try(lower(each.value.acl), null) == "private" ? true : false
  block_public_policy    = try(lower(each.value.acl), null) == "private" ? true : false
  ignore_public_acls     = try(lower(each.value.acl), null) == "private" ? true : false
  restrict_public_buckets = try(lower(each.value.acl), null) == "private" ? true : false
}

resource "aws_s3_bucket_versioning" "versioning" {
  for_each = local.configs
  bucket   = aws_s3_bucket.this[each.key].id

  versioning_configuration {
    status = each.value.enable_versioning ? "Enabled" : "Suspended"
  }
}
