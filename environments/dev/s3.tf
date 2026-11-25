# -----------------------------------------------------------------------------
# Application S3 bucket: files the app reads and writes (uploads, exports...).
# Registry module: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws
# -----------------------------------------------------------------------------
module "app_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.18"

  bucket = local.app_bucket_name

  # When protection is OFF, `terraform destroy` also deletes every object in the bucket.
  force_destroy = !var.deletion_protection

  # Keep old versions of objects, so files deleted or overwritten by mistake can be recovered.
  versioning = {
    enabled = true
  }

  # Encrypt at rest (SSE-S3, free).
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  # Private bucket: block all forms of public access.
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # ACLs off: access is controlled only by IAM policies.
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  # HTTPS only, modern TLS only.
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  # Clean up: old object versions after 30 days, failed uploads after 7.
  lifecycle_rule = [
    {
      id      = "cleanup"
      enabled = true
      filter  = { prefix = "" }

      noncurrent_version_expiration = {
        noncurrent_days = 30
      }
      abort_incomplete_multipart_upload_days = 7
    }
  ]
}
