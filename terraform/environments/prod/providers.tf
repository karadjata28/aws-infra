provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile # AWS CLI profile = which account you are logged into

  # Safety net: Terraform refuses to run if the profile points to any other account.
  # This is what stops prod resources landing in the dev account (or the reverse).
  allowed_account_ids = [var.aws_account_id]

  # Added to every resource: makes it easy to tell what belongs to which env/project.
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
