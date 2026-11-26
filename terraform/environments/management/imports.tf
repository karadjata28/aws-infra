# -----------------------------------------------------------------------------
# These resources were created by hand (AWS CLI) before this code existed.
# `import` blocks tell Terraform "this already exists, take it over instead of
# creating a new one". The first `terraform plan` should show "4 to import, 0 to add,
# 3 to change, 0 to destroy", where the 3 changes only add the default tags.
#
# After the first successful `terraform apply`, the resources are in the state and
# this file can be deleted (keeping it is harmless).
# -----------------------------------------------------------------------------

import {
  to = aws_iam_role.budgets_action
  id = "BudgetsSpendLimitActionRole"
}

import {
  to = aws_iam_role_policy.budgets_attach_scp
  id = "BudgetsSpendLimitActionRole:AttachDetachSCP"
}

import {
  to = aws_budgets_budget.monthly
  id = "${var.aws_account_id}:${var.budget_name}"
}

import {
  to = aws_budgets_budget_action.block_new_resources
  id = "${var.aws_account_id}:236b5301-18ac-4f09-8363-b1bbd821ade3:${var.budget_name}"
}
