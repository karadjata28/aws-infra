# --- General -----------------------------------------------------------------

variable "aws_region" {
  description = "AWS region for all resources in this environment."
  type        = string
  default     = "eu-central-1"
}

variable "project" {
  description = "Short project name, used as a prefix for resource names."
  type        = string
  default     = "training"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,20}$", var.project))
    error_message = "project must be 3-20 characters: lowercase letters, numbers and hyphens only."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod...)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

# --- Safety ------------------------------------------------------------------

variable "deletion_protection" {
  description = <<-EOT
    Protects the app bucket and table from being deleted by mistake.
    true  = the table can't be deleted, and the bucket can't be deleted while it has objects.
    false = `terraform destroy` removes everything, including data. Set this before destroying.
  EOT
  type        = bool
  default     = true
}

# --- IAM ---------------------------------------------------------------------

variable "enforce_mfa" {
  description = <<-EOT
    Require MFA for the IAM users. Until a user sets up MFA, they can do almost nothing
    except set up MFA (best practice). Set to false only for quick CLI experiments.
  EOT
  type        = bool
  default     = true
}

variable "app_service_principals" {
  description = "AWS services allowed to assume the app role (the compute that runs your app)."
  type        = list(string)
  default     = ["lambda.amazonaws.com"]
}
