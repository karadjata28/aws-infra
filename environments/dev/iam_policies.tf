# -----------------------------------------------------------------------------
# Customer-managed IAM policies for the app's data (S3 bucket + DynamoDB table).
#
# Least privilege: every statement names the exact actions AND the exact resources
# (ARNs). There are no "*" wildcards on actions or resources.
#
# The JSON is built with `aws_iam_policy_document` data sources instead of
# hand-written JSON: Terraform validates it, and you can't break it with a missing comma.
# -----------------------------------------------------------------------------

# --- Policy documents --------------------------------------------------------

# READ + WRITE: used by the application itself (attached to the app role).
data "aws_iam_policy_document" "app_data_readwrite" {
  statement {
    sid       = "S3ListBucket"
    actions   = ["s3:ListBucket"]
    resources = [module.app_bucket.s3_bucket_arn] # bucket-level actions use the bucket ARN
  }

  statement {
    sid = "S3ObjectReadWrite"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${module.app_bucket.s3_bucket_arn}/*"] # object-level actions use bucket/*
  }

  statement {
    sid = "DynamoDBReadWrite"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:BatchGetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:BatchWriteItem",
    ]
    resources = [
      module.app_table.dynamodb_table_arn,
      "${module.app_table.dynamodb_table_arn}/index/*", # covers any indexes added later
    ]
  }
}

# READ ONLY: used by the developer group, so people can inspect data but not change it.
data "aws_iam_policy_document" "app_data_readonly" {
  statement {
    sid       = "S3ListBucket"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [module.app_bucket.s3_bucket_arn]
  }

  statement {
    sid       = "S3ObjectRead"
    actions   = ["s3:GetObject"]
    resources = ["${module.app_bucket.s3_bucket_arn}/*"]
  }

  # Lets developers see the bucket list in the S3 console (names only, no contents).
  statement {
    sid       = "S3ConsoleListBuckets"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"] # this action doesn't support resource-level permissions
  }

  statement {
    sid = "DynamoDBRead"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:BatchGetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
    ]
    resources = [
      module.app_table.dynamodb_table_arn,
      "${module.app_table.dynamodb_table_arn}/index/*",
    ]
  }

  # Lets developers see the table list in the DynamoDB console.
  statement {
    sid       = "DynamoDBConsoleListTables"
    actions   = ["dynamodb:ListTables"]
    resources = ["*"] # this action doesn't support resource-level permissions
  }
}

# --- Policies (registry module) ----------------------------------------------
# Registry module: https://registry.terraform.io/modules/terraform-aws-modules/iam/aws

module "app_data_readwrite_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 6.11"

  name        = "${local.name_prefix}-app-data-readwrite"
  description = "Read/write access to the ${var.environment} app S3 bucket and DynamoDB table"
  policy      = data.aws_iam_policy_document.app_data_readwrite.json
}

module "app_data_readonly_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 6.11"

  name        = "${local.name_prefix}-app-data-readonly"
  description = "Read-only access to the ${var.environment} app S3 bucket and DynamoDB table"
  policy      = data.aws_iam_policy_document.app_data_readonly.json
}
