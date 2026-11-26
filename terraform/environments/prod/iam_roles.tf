module "app_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.11"

  name            = "${local.name_prefix}-app"
  use_name_prefix = false
  description     = "Role assumed by the ${var.environment} app to access its S3 bucket and DynamoDB table"

  trust_policy_permissions = {
    AllowServiceAssume = {
      actions = ["sts:AssumeRole"]
      principals = [{
        type        = "Service"
        identifiers = var.app_service_principals
      }]
      condition = [{
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = [local.account_id]
      }]
    }
  }

  policies = {
    AppDataReadWrite = module.app_data_readwrite_policy.arn
  }

  create_instance_profile = false
}
