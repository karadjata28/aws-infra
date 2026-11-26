variable "aws_profile" {
  description = "AWS CLI profile used to log into this environment's account (see ~/.aws/config)."
  type        = string
  default     = "default"
}

variable "aws_account_id" {
  description = "ID of this environment's AWS account. Terraform stops if the profile is logged into a different account."
  type        = string
  default     = "607520121097"

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must be exactly 12 digits."
  }
}

variable "aws_region" {
  description = "AWS region for all resources in this environment."
  type        = string
  default     = "eu-central-1"
}

variable "project" {
  description = "Short project name, used as a prefix for resource names. Must match bootstrap."
  type        = string
  default     = "training"

  validation {
    condition     = can(regex("^[a-z0-9-]{3,20}$", var.project))
    error_message = "project must be 3-20 characters: lowercase letters, numbers and hyphens only."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "deletion_protection" {
  description = <<-EOT
    Protects the app bucket and table from being deleted by mistake.
    true  = the table can't be deleted, and the bucket can't be deleted while it has objects.
    false = `terraform destroy` removes everything, including data. Set this before destroying.
  EOT
  type        = bool
  default     = true
}

variable "app_version_retention_days" {
  description = "How many days to keep OLD versions of objects in the app bucket (for recovery)."
  type        = number
  default     = 30
}

variable "app_service_principals" {
  description = "AWS services allowed to assume the app role (the compute that runs your app)."
  type        = list(string)
  default     = ["lambda.amazonaws.com"]
}
