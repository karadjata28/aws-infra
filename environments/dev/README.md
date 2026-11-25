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
cp terraform.tfvars.example terraform.tfvars   # fill in the Develop account ID
cp backend.hcl.example backend.hcl             # or: (cd ../../bootstrap && terraform workspace select develop && terraform output -raw backend_hcl) > backend.hcl

terraform init -backend-config=backend.hcl
terraform fmt -check    # formatting
terraform validate      # syntax and types
terraform plan -out=tfplan
terraform apply tfplan  # applies exactly what you reviewed
```

`aws_account_id` in `terraform.tfvars` is a safety net: if the profile is logged into any
other account, Terraform stops before it changes anything.

## Other environments

`../prod` has the same `.tf` code with different values, in the Production account. See
[../prod/README.md](../prod/README.md).

## Destroy

1. Set `deletion_protection = false` in `terraform.tfvars` and run `terraform apply`.
2. Run `terraform destroy`.
