# environments/management — organisation settings (Management account)

The Management account runs **no applications**. It only holds things that apply to the
whole organisation:

| File | What's in it |
|------|--------------|
| `budgets.tf` | $20/month budget for ALL accounts, email alerts, and an automatic block on new paid resources at 90% |
| `iam.tf` | The role AWS Budgets uses to apply that block |
| `organization.tf` | Read-only lookup of the organisation and its accounts, plus what is deliberately left out |
| `imports.tf` | Takes over the budget and role that were created by hand before this code existed |
| `backend.tf` / `backend.hcl.example` | State in the Management account's own bucket |
| `versions.tf`, `providers.tf`, `variables.tf`, `outputs.tf` | The usual |

## What is NOT in Terraform, and why

| Thing | Managed by |
|-------|-----------|
| The organisation, the accounts, IAM Identity Center (SSO) | AWS's guided multi-account setup. It also disables permission sets, so SSO access can't be written in Terraform |
| Roles named `AWSManaged*` and `AccountFullAccessRole` | AWS (protected by an SCP) |
| SCPs `FullAWSAccess`, `ManagedAccountSecurityControlPolicy`, `BudgetsSpendLimit*` | AWS |

## Usage

Run `../../bootstrap` for the Management account first.

```bash
aws login --profile management

cp backend.hcl.example backend.hcl   # emails and account IDs are the defaults in variables.tf

terraform init -backend-config=backend.hcl
terraform plan -out=tfplan
```

The first plan should say **"4 to import, 0 to add, 3 to change, 0 to destroy"**. The 3
changes only add the `default_tags` (`ManagedBy = "Terraform"` etc.) to the budget, the
budget action and the role. If it wants to change anything else, or to replace or destroy
something, the code doesn't match AWS yet: fix the code, don't apply.

```bash
terraform apply tfplan   # only records the imports in the state, changes nothing in AWS
```
