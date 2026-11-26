data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  name_prefix = "${var.project}-${var.environment}"

  app_bucket_name = "${local.name_prefix}-app-${local.account_id}"
  app_table_name  = "${local.name_prefix}-app-data"
}
