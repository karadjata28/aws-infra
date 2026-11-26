data "aws_organizations_organization" "this" {}

locals {
  accounts = {
    for a in data.aws_organizations_organization.this.accounts : a.name => a.id
    if a.status == "ACTIVE"
  }
}
