# Input variables: values you can change without editing the code.
# Each account has its own values file (see the *.tfvars.example files).

variable "aws_profile" {
  description = "AWS CLI profile used to log into the target account (see ~/.aws/config)."
  type        = string
}

variable "aws_account_id" {
  description = "ID of the account this bucket belongs to. Terraform stops if the profile is logged into a different account."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must be exactly 12 digits."
  }
}

variable "aws_region" {
  description = "AWS region where the state bucket is created."
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
