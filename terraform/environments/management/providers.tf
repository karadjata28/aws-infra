provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile # AWS CLI profile that logs into the Management account

  # Safety net: Terraform refuses to run if the profile points to any other account.
  allowed_account_ids = [var.aws_account_id]

  default_tags {
    tags = {
      Project     = var.project
      Environment = "management"
      ManagedBy   = "Terraform"
    }
  }
}
