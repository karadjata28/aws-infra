data "aws_iam_policy_document" "budgets_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["budgets.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "budgets_attach_scp" {
  statement {
    actions = [
      "organizations:AttachPolicy",
      "organizations:DetachPolicy",
      "organizations:DescribePolicy",
      "organizations:ListPolicies",
      "organizations:ListTargetsForPolicy",
      "organizations:DescribeOrganization",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "budgets_action" {
  name               = "BudgetsSpendLimitActionRole"
  assume_role_policy = data.aws_iam_policy_document.budgets_trust.json
}

resource "aws_iam_role_policy" "budgets_attach_scp" {
  name   = "AttachDetachSCP"
  role   = aws_iam_role.budgets_action.id
  policy = data.aws_iam_policy_document.budgets_attach_scp.json
}
