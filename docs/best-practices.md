# Best practices used in this repo

## Accounts

| Practice | Where | Why |
|----------|-------|-----|
| One AWS account per environment | `environments/dev` → Develop, `environments/prod` → Production | A mistake or a breach in dev can't reach prod |
| Management account runs no workloads | `environments/management` | It controls billing and every other account, and SCPs can't restrict it |
| `allowed_account_ids` on every provider | `providers.tf` | Terraform refuses to run against the wrong account |
| One org-wide budget with an automatic block | `environments/management/budgets.tf` | Spending can't quietly run away |

## Terraform

| Practice | Where | Why |
|----------|-------|-----|
| Remote state in S3, one bucket per account | `bootstrap/`, `backend.tf` | Shared and backed-up state, kept inside the account it describes |
| S3-native locking (`use_lockfile = true`) | `backend.hcl` | No two runs at once, without a DynamoDB table (DynamoDB locking is deprecated) |
| Separate bootstrap stack, one workspace per account | `bootstrap/` | The state bucket can't store its own state |
| One state file per environment | `key = "dev/..."` | A mistake in dev can't touch prod |
| Partial backend config | `backend.hcl` | Account-specific values stay out of the code |
| `import` blocks for things made by hand | `environments/management/imports.tf` | Take over existing resources without recreating them |
| Pinned versions (`~> x.y`) | `versions.tf`, every `module` | The same code always gives the same result |
| Commit `.terraform.lock.hcl` | each stack | Everyone uses the exact same provider build |
| Registry modules | most resources | Battle-tested code, less to write and maintain |
| One file per concern | `s3.tf`, `iam_roles.tf`, ... | Easy to find things |
| Variables with `description`, `type` and `validation` | `variables.tf` | Self-documenting, and bad input fails early |
| `default_tags` | `providers.tf` | Every resource is tagged with no extra effort |
| `aws_iam_policy_document` instead of raw JSON | `iam_policies.tf`, `iam.tf` | Validated by Terraform, and easier to read |
| `plan -out` then `apply <plan>` | READMEs | You apply exactly what you reviewed |
| Real IDs and emails only in git-ignored files | `*.tfvars`, `backend.hcl` | Nothing personal ends up in git |

## AWS security

| Practice | Where |
|----------|-------|
| People sign in through SSO, no IAM users | `docs/iam.md` |
| S3: block all public access, ACLs off, encrypted, HTTPS only, versioning on | `bootstrap/main.tf`, `s3.tf` |
| DynamoDB: deletion protection, point-in-time recovery | `dynamodb.tf` |
| Least privilege: exact actions on exact ARNs | `iam_policies.tf` |
| Roles (temporary credentials) for services, not access keys | `iam_roles.tf` |
| `aws:SourceAccount` condition on the trust policy | `iam_roles.tf` |

## Next steps you could add

- `pre-commit` hooks running `terraform fmt`, `tflint` and `checkov`
- A CI pipeline that runs `plan` on pull requests
- Move the dev/prod code into a shared module in `modules/` to remove the copy
- Switch the Develop `default` profile from an access key to `aws login`
