module "app_table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 5.5"

  name = local.app_table_name

  hash_key  = "pk"
  range_key = "sk"
  attributes = [
    { name = "pk", type = "S" },
    { name = "sk", type = "S" },
  ]

  billing_mode = "PAY_PER_REQUEST"

  point_in_time_recovery_enabled = true

  deletion_protection_enabled = var.deletion_protection

  ttl_enabled        = true
  ttl_attribute_name = "expires_at"
}
