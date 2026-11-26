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
