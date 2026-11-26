# -----------------------------------------------------------------------------
# Organisation-wide spending limit.
#
# A budget in the Management account counts the cost of EVERY account in the
# organisation (consolidated billing), so one budget covers Develop and Production.
#
#   25 / 50 / 80 / 100 % actual  -> email
#   100 % forecasted             -> email ("you're on track to go over")
#   90 % actual                  -> AWS Budgets attaches the spend-limit SCP to the
#                                   workload accounts: new paid resources are blocked.
#
# Note: there is no true hard cap in AWS. The block stops NEW resources; anything
# already running keeps costing money until you delete it.
# -----------------------------------------------------------------------------

resource "aws_budgets_budget" "monthly" {
  name         = var.budget_name
  budget_type  = "COST"
  limit_amount = var.monthly_budget_usd
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # Count usage BEFORE credits, so the limit protects the free credits too.
  cost_types {
    include_credit = false
    include_refund = false
  }

  # Emails when actual spend passes each threshold.
  dynamic "notification" {
    for_each = var.alert_thresholds_percent
    content {
      notification_type          = "ACTUAL"
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value
      threshold_type             = "PERCENTAGE"
      subscriber_email_addresses = var.alert_emails
    }
  }

  # Early warning: AWS forecasts that this month will go over the limit.
  notification {
    notification_type          = "FORECASTED"
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    subscriber_email_addresses = var.alert_emails
  }
}

# Automatic block: at block_threshold_percent of actual spend, attach the spend-limit
# SCP to the workload accounts. To lift the block, detach the SCP from those accounts
# (or wait for the next month and reset the action in the Budgets console).
resource "aws_budgets_budget_action" "block_new_resources" {
  budget_name        = aws_budgets_budget.monthly.name
  action_type        = "APPLY_SCP_POLICY"
  approval_model     = "AUTOMATIC"
  notification_type  = "ACTUAL"
  execution_role_arn = aws_iam_role.budgets_action.arn

  action_threshold {
    action_threshold_type  = "PERCENTAGE"
    action_threshold_value = var.block_threshold_percent
  }

  definition {
    scp_action_definition {
      policy_id  = var.spend_limit_scp_id
      target_ids = var.workload_account_ids
    }
  }

  dynamic "subscriber" {
    for_each = var.alert_emails
    content {
      address           = subscriber.value
      subscription_type = "EMAIL"
    }
  }
}
