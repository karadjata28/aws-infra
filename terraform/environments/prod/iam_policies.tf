data "aws_iam_policy_document" "app_data_readwrite" {
  statement {
    sid       = "S3ListBucket"
    actions   = ["s3:ListBucket"]
    resources = [module.app_bucket.s3_bucket_arn]
  }

  statement {
    sid = "S3ObjectReadWrite"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${module.app_bucket.s3_bucket_arn}/*"]
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
      "${module.app_table.dynamodb_table_arn}/index/*",
    ]
  }
}

module "app_data_readwrite_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 6.11"

  name        = "${local.name_prefix}-app-data-readwrite"
  description = "Read/write access to the ${var.environment} app S3 bucket and DynamoDB table"
  policy      = data.aws_iam_policy_document.app_data_readwrite.json
}
