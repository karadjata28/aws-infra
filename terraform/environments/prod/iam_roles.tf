# -----------------------------------------------------------------------------
# App role: how AWS SERVICES (not people) get permissions.
#
# The compute that runs your app (Lambda by default, or EC2/ECS) "assumes" this
# role and gets short-lived credentials that rotate automatically. That's how the
# app talks to the S3 bucket and DynamoDB table with no stored access keys.
#
#   Lambda --assumes--> app role --app-data-readwrite--> S3 bucket + DynamoDB table
#
# Registry module: https://registry.terraform.io/modules/terraform-aws-modules/iam/aws
# -----------------------------------------------------------------------------
module "app_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.11"

  name            = "${local.name_prefix}-app"
  use_name_prefix = false # exact name, instead of name + random suffix
  description     = "Role assumed by the ${var.environment} app to access its S3 bucket and DynamoDB table"

  # TRUST policy = WHO may assume this role (here: the AWS services you list).
  trust_policy_permissions = {
    AllowServiceAssume = {
      actions = ["sts:AssumeRole"]
      principals = [{
        type        = "Service"
        identifiers = var.app_service_principals
      }]
      # Protects against the "confused deputy" problem: only services acting for
      # THIS account can assume the role.
      condition = [{
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = [local.account_id]
      }]
    }
  }

  # PERMISSION policies = WHAT the role can do once assumed.
  policies = {
    AppDataReadWrite = module.app_data_readwrite_policy.arn
  }

  # Set to true if the app runs on EC2: EC2 needs an "instance profile" wrapping the role.
  create_instance_profile = false
}
