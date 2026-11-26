provider "aws" {
  region  = var.aws_region
  profile = local.account.profile

  allowed_account_ids = [local.account.account_id]
  default_tags {
    tags = {
      Project   = var.project
      ManagedBy = "Terraform"
      Stack     = "bootstrap"
    }
  }
}
