# Locals are named values computed inside the configuration (not user inputs).
# They keep names consistent and avoid repeating the same expression everywhere.

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  # Every resource name starts with this, e.g. "training-dev-app-data"
  name_prefix = "${var.project}-${var.environment}"

  # S3 bucket names are globally unique, so we add the account ID.
  app_bucket_name = "${local.name_prefix}-app-${local.account_id}"
  app_table_name  = "${local.name_prefix}-app-data"
}
