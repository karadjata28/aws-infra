# Pin the Terraform CLI and provider versions so every run behaves the same.
# "~> 6.0" means: any 6.x version, but never 7.0 (major versions can break things).
terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # No "backend" block here on purpose: bootstrap uses LOCAL state,
  # because the remote-state bucket doesn't exist yet. See README.md.
}
