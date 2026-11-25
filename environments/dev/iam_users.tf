# -----------------------------------------------------------------------------
# IAM users and groups.
#
# Best practice: give permissions to GROUPS, then put users in groups.
# Never attach policies directly to users. To change what someone can do,
# you move them to a different group.
#
#   admin user      -> admins group     -> AdministratorAccess
#   developer user  -> developers group -> app-data-readonly (+ read-only console views)
#
# Both groups also get a "self-management" policy (from the module) so users can
# change their own password and set up MFA. Optionally MFA is enforced.
# -----------------------------------------------------------------------------

# --- Users -------------------------------------------------------------------

module "admin_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "~> 6.11"

  name = "${local.name_prefix}-admin"

  # Don't create passwords or access keys in Terraform: they would be saved in the
  # state file. Create them yourself after apply (see docs/iam.md).
  create_login_profile = false
  create_access_key    = false

  # Lets `terraform destroy` remove the user even if you added keys/MFA by hand.
  force_destroy = true
}

module "developer_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "~> 6.11"

  name = "${local.name_prefix}-developer"

  create_login_profile = false
  create_access_key    = false
  force_destroy        = true
}

# --- Groups ------------------------------------------------------------------

module "admins_group" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group"
  version = "~> 6.11"

  name  = "${local.name_prefix}-admins"
  users = [module.admin_user.name]

  # Module-created policy: users can manage their own password, keys and MFA.
  enable_self_management_permissions = true
  enable_mfa_enforcement             = var.enforce_mfa

  # AWS-managed policy giving full access to everything.
  policies = {
    AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
  }
}

module "developers_group" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group"
  version = "~> 6.11"

  name  = "${local.name_prefix}-developers"
  users = [module.developer_user.name]

  enable_self_management_permissions = true
  enable_mfa_enforcement             = var.enforce_mfa

  # Limited access: read-only on this app's data, nothing else.
  policies = {
    AppDataReadOnly = module.app_data_readonly_policy.arn
  }
}
