provider "aws" {
  region = var.aws_region

  # Added to every resource: makes it easy to tell what belongs to which env/project.
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
