provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile # AWS CLI profile = which account you are logged into

  # Safety net: Terraform refuses to run if the profile points to any other account.
  # This stops you creating the bucket in the wrong account by mistake.
  allowed_account_ids = [var.aws_account_id]

  # default_tags are added to EVERY resource this provider creates.
  # Tags make it easy to find, filter and track the cost of resources.
  default_tags {
    tags = {
      Project   = var.project
      ManagedBy = "Terraform"
      Stack     = "bootstrap"
    }
  }
}
