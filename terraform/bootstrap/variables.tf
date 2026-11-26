variable "accounts" {
  description = "One entry per AWS account. The key is the workspace name."
  type = map(object({
    profile    = string
    account_id = string
  }))
  default = {
    management = { profile = "management", account_id = "060502546384" }
    develop    = { profile = "default", account_id = "607520121097" }
    production = { profile = "production", account_id = "844153410920" }
  }

  validation {
    condition     = alltrue([for a in values(var.accounts) : can(regex("^[0-9]{12}$", a.account_id))])
    error_message = "Every account_id must be exactly 12 digits."
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

locals {
  account = var.accounts[terraform.workspace]
}
