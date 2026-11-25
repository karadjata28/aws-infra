# -----------------------------------------------------------------------------
# Application DynamoDB table: stores the app's data (records/items).
# Registry module: https://registry.terraform.io/modules/terraform-aws-modules/dynamodb-table/aws
# -----------------------------------------------------------------------------
module "app_table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 5.5"

  name = local.app_table_name

  # Primary key. "pk" (partition key) + "sk" (sort key) is a common, flexible pattern:
  #   pk = "USER#123"  sk = "PROFILE"
  #   pk = "USER#123"  sk = "ORDER#2026-11-25"
  # Only key attributes are declared here. DynamoDB has no schema for other fields.
  hash_key  = "pk"
  range_key = "sk"
  attributes = [
    { name = "pk", type = "S" },
    { name = "sk", type = "S" },
  ]

  # On-demand: no capacity planning, you pay per request. Good default for small apps.
  billing_mode = "PAY_PER_REQUEST"

  # Continuous backups: restore the table to any second in the last 35 days.
  point_in_time_recovery_enabled = true

  # Stops the table being deleted by mistake (see var.deletion_protection).
  deletion_protection_enabled = var.deletion_protection

  # Items with an "expires_at" attribute (Unix timestamp) are deleted automatically.
  # Items without it are kept forever. Useful for sessions, temp data, etc.
  ttl_enabled        = true
  ttl_attribute_name = "expires_at"
}
