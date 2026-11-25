# -----------------------------------------------------------------------------
# Remote state backend: one S3 bucket (state files) + one DynamoDB table (locks).
# These are shared by every environment; each environment uses its own state
# "key" (path) inside the bucket, e.g. dev/terraform.tfstate.
# -----------------------------------------------------------------------------

# Looks up the AWS account we're logged into. We add the account ID to the bucket
# name because S3 bucket names must be unique across ALL AWS accounts worldwide.
data "aws_caller_identity" "current" {}

locals {
  state_bucket_name = "${var.project}-tfstate-${data.aws_caller_identity.current.account_id}"
  lock_table_name   = "${var.project}-tf-locks"
}

# --- S3 bucket for Terraform state -------------------------------------------
# Registry module: https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws
module "state_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.18" # pin the module version, same idea as pinning providers

  bucket = local.state_bucket_name

  # Never delete the bucket while it still holds state files.
  force_destroy = false

  # Versioning keeps every previous state file, so you can roll back if state
  # gets corrupted or someone makes a bad change.
  versioning = {
    enabled = true
  }

  # Encrypt all objects at rest. SSE-S3 (AES256) is free; use "aws:kms" with
  # your own KMS key if you need control over the key.
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  # State can contain secrets, so it must NEVER be public.
  # (These are the module defaults, but writing them out makes the intent clear.)
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Turn off ACLs: access is controlled only by IAM and bucket policies.
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  # Bucket policy that rejects plain HTTP and old TLS versions.
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  # Delete old state versions after N days so the bucket doesn't grow forever.
  lifecycle_rule = [
    {
      id      = "expire-old-state-versions"
      enabled = true
      filter  = { prefix = "" } # apply to every object

      noncurrent_version_expiration = {
        noncurrent_days = var.state_version_retention_days
      }
      abort_incomplete_multipart_upload_days = 7
    }
  ]
}

# --- DynamoDB table for state locking ----------------------------------------
# While `plan`/`apply` runs, Terraform writes a lock item here. A second run
# sees the lock and waits/fails instead of corrupting the state.
# Registry module: https://registry.terraform.io/modules/terraform-aws-modules/dynamodb-table/aws
module "lock_table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 5.5"

  name = local.lock_table_name

  # The S3 backend REQUIRES the partition key to be called exactly "LockID" (string).
  hash_key = "LockID"
  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]

  # On-demand billing: you pay per request. Lock traffic is tiny, so it's almost free.
  billing_mode = "PAY_PER_REQUEST"

  # Stop the table being deleted by mistake (even from the console).
  deletion_protection_enabled = true

  # Data is always encrypted at rest with an AWS-owned key. We don't need a KMS key
  # for lock items, so leave the module's KMS option off.
  server_side_encryption_enabled = false
}
