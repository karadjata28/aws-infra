output "accounts" {
  description = "Active accounts in the organisation (name => ID)."
  value       = local.accounts
}

output "budget_name" {
  description = "Name of the organisation-wide monthly budget."
  value       = aws_budgets_budget.monthly.name
}

output "budgets_action_role_arn" {
  description = "Role AWS Budgets uses to block new resources at the limit."
  value       = aws_iam_role.budgets_action.arn
}
