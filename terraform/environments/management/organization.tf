# -----------------------------------------------------------------------------
# The Management account holds NO application infrastructure. It only holds things
# that apply to the whole organisation: the spending limit (budgets.tf) and the role
# that enforces it (iam.tf).
#
# What is deliberately NOT managed by Terraform here, and why:
#
#   - The organisation, its accounts and IAM Identity Center (SSO): they were created
#     by AWS's guided multi-account setup, which keeps managing them. That setup also
#     turns off permission sets, so SSO access can't be written in Terraform.
#   - AWS-managed roles (AWSManaged*, AccountFullAccessRole) and SCPs
#     (FullAWSAccess, ManagedAccountSecurityControlPolicy, BudgetsSpendLimit*):
#     AWS owns and protects them. If Terraform managed them too, the two would fight.
#
# The data sources below only READ the organisation, so other files can use the
# account list without managing it.
# -----------------------------------------------------------------------------

data "aws_organizations_organization" "this" {}

locals {
  # Map of account name => ID, e.g. { Develop = "...", Production = "..." }
  accounts = {
    for a in data.aws_organizations_organization.this.accounts : a.name => a.id
    if a.status == "ACTIVE"
  }
}
