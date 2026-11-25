# --- Account -----------------------------------------------------------------

variable "aws_profile" {
  description = "AWS CLI profile that logs into the Management account (see ~/.aws/config)."
  type        = string
  default     = "management"
}

variable "aws_account_id" {
  description = "ID of the Management account. Terraform stops if the profile is logged into a different account."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must be exactly 12 digits."
  }
}

variable "aws_region" {
  description = "Default region. Budgets and IAM are global, so this mostly doesn't matter here."
  type        = string
  default     = "eu-central-1"
}

variable "project" {
  description = "Short project name, used in tags."
  type        = string
  default     = "training"
}

# --- Spending limit ----------------------------------------------------------

variable "budget_name" {
  description = "Name of the organisation-wide monthly budget."
  type        = string
  default     = "Monthly-20USD"
}

variable "monthly_budget_usd" {
  description = "Monthly limit in USD for ALL accounts together (usage before credits)."
  type        = string
  default     = "20.0"
}

variable "alert_emails" {
  description = "Who gets the budget emails. Keep the real addresses in terraform.tfvars (git-ignored)."
  type        = list(string)

  validation {
    condition     = length(var.alert_emails) > 0
    error_message = "Add at least one email address, or nobody will hear about overspending."
  }
}

variable "alert_thresholds_percent" {
  description = "Send an email when ACTUAL spend passes these percentages of the budget."
  type        = list(number)
  default     = [25, 50, 80, 100]
}

variable "block_threshold_percent" {
  description = "At this percentage of ACTUAL spend, new paid resources are blocked in the workload accounts."
  type        = number
  default     = 90
}

variable "workload_account_ids" {
  description = "Accounts that get blocked when the limit is reached (Develop and Production). Never the Management account."
  type        = list(string)
}

variable "spend_limit_scp_id" {
  description = "ID of the SCP that blocks new paid resources. It was created by AWS Budgets, so Terraform only references it."
  type        = string
}
