# Input variables: values you can change without editing the code.
# Set them in terraform.tfvars (copy terraform.tfvars.example).

variable "aws_region" {
  description = "AWS region where the state bucket and lock table are created."
  type        = string
  default     = "eu-central-1"
}

variable "project" {
  description = "Short project name. Used as a prefix for resource names."
  type        = string
  default     = "training"

  # Validation catches bad input at plan time instead of failing in AWS.
  # S3 bucket names only allow lowercase letters, numbers and hyphens.
  validation {
    condition     = can(regex("^[a-z0-9-]{3,20}$", var.project))
    error_message = "project must be 3-20 characters: lowercase letters, numbers and hyphens only."
  }
}

variable "state_version_retention_days" {
  description = "How many days to keep OLD versions of the state file (for rollback)."
  type        = number
  default     = 90
}
