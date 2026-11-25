# Best practices used in this repo

## Terraform

| Practice | Where | Why |
|----------|-------|-----|
| Remote state in S3 + DynamoDB lock | `bootstrap/`, `backend.tf` | Shared and backed-up state, and no two runs at once |
| Separate bootstrap stack | `bootstrap/` | The state bucket can't store its own state |
| One state file per environment | `key = "dev/..."` | A mistake in dev can't touch prod |
| Partial backend config | `backend.hcl` | Account-specific values stay out of the code |
| Pinned versions (`~> x.y`) | `versions.tf`, every `module` | The same code always gives the same result |
| Commit `.terraform.lock.hcl` | repo root of each stack | Everyone uses the exact same provider build |
| Registry modules | every resource | Battle-tested code, less to write and maintain |
| One file per concern | `s3.tf`, `iam_users.tf`, ... | Easy to find things |
| Variables with `description`, `type` and `validation` | `variables.tf` | Self-documenting, and bad input fails early |
| `default_tags` | `providers.tf` | Every resource is tagged with no extra effort |
| `aws_iam_policy_document` instead of raw JSON | `iam_policies.tf` | Validated by Terraform, and easier to read |
| `plan -out` then `apply <plan>` | READMEs | You apply exactly what you reviewed |
| Secrets never in state | `iam_users.tf` | State is readable by anyone who can read the bucket |

## AWS security

| Practice | Where |
|----------|-------|
| S3: block all public access, ACLs off, encrypted, HTTPS only, versioning on | `bootstrap/main.tf`, `s3.tf` |
| DynamoDB: deletion protection, point-in-time recovery | `dynamodb.tf` |
| Permissions on groups, not on users | `iam_users.tf` |
| Least privilege: exact actions on exact ARNs | `iam_policies.tf` |
| Roles (temporary credentials) for services, not access keys | `iam_roles.tf` |
| `aws:SourceAccount` condition on the trust policy | `iam_roles.tf` |
| MFA enforcement for users | `iam_users.tf` (`enforce_mfa`) |

## Next steps you could add

- `pre-commit` hooks running `terraform fmt`, `tflint` and `checkov`
- A CI pipeline that runs `plan` on pull requests
- Use IAM Identity Center (SSO) instead of IAM users in real organisations
- Terraform 1.10+ also supports S3-native locking (`use_lockfile = true`) with no
  DynamoDB table. HashiCorp now recommends it, and DynamoDB locking is deprecated.
