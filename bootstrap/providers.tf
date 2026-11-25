provider "aws" {
  region = var.aws_region

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
