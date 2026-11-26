# environments/dev — application infrastructure (Develop account)

The dev environment. It is deployed into the **Develop** AWS account. Its state is stored
in the Develop account's own bootstrap bucket at `dev/terraform.tfstate`, locked with an
S3 lock file (`use_lockfile = true`).

## Files (one file per concern)

| File | What's in it |
|------|--------------|
| `backend.tf` / `backend.hcl.example` | Where the state is stored (S3 bucket in the Develop account) |
| `versions.tf`, `providers.tf` | Version pins, AWS provider, account guard, default tags |
| `variables.tf`, `locals.tf` | Inputs and computed names |
| `s3.tf` | App S3 bucket |
| `dynamodb.tf` | App DynamoDB table (`pk`/`sk` keys, PITR backups, TTL) |
| `iam_policies.tf` | Read/write policy for the app's data |
| `iam_roles.tf` | App role that the app's compute service assumes |
| `outputs.tf` | Names and ARNs printed after apply |

There are no IAM users here: people sign in through SSO. See [../../docs/iam.md](../../docs/iam.md).

## Usage

Run `../../bootstrap` for the Develop account first.

```bash
cp backend.hcl.example backend.hcl   # or: (cd ../../bootstrap && terraform workspace select develop && terraform output -raw backend_hcl) > backend.hcl

terraform init -backend-config=backend.hcl
terraform fmt -check    # formatting
terraform validate      # syntax and types
terraform plan -out=tfplan
terraform apply tfplan  # applies exactly what you reviewed
```

All values are the `default`s in `variables.tf` (there is no `terraform.tfvars`).
`aws_account_id` is a safety net: if the profile is logged into any other account,
Terraform stops before it changes anything.

## Other environments

`../prod` has the same `.tf` code in the Production account. Only `variables.tf` (the
values) and `backend.tf` (the state key) differ. See [../prod/README.md](../prod/README.md).

## Destroy

1. Set the `deletion_protection` default to `false` in `variables.tf` and run `terraform apply`.
2. Run `terraform destroy`.
