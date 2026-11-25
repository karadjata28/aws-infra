# environments/dev — application infrastructure

The dev environment. Its state is stored remotely in the bootstrap bucket at
`dev/terraform.tfstate` and locked with the DynamoDB lock table.

## Files (one file per concern)

| File | What's in it |
|------|--------------|
| `backend.tf` / `backend.hcl.example` | Where the state is stored (S3 + DynamoDB lock) |
| `versions.tf`, `providers.tf` | Version pins, AWS provider, default tags |
| `variables.tf`, `locals.tf` | Inputs and computed names |
| `s3.tf` | App S3 bucket |
| `dynamodb.tf` | App DynamoDB table (`pk`/`sk` keys, PITR backups, TTL) |
| `iam_policies.tf` | Read/write and read-only policies for the app's data |
| `iam_users.tf` | `admin` and `developer` users and their groups |
| `iam_roles.tf` | App role that the app's compute service assumes |
| `outputs.tf` | Names and ARNs printed after apply |

See [../../docs/iam.md](../../docs/iam.md) for who can access what.

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
cp backend.hcl.example backend.hcl   # or: (cd ../../bootstrap && terraform output -raw backend_hcl) > backend.hcl

terraform init -backend-config=backend.hcl
terraform fmt -check    # formatting
terraform validate      # syntax and types
terraform plan -out=tfplan
terraform apply tfplan  # applies exactly what you reviewed
```

> `init` shows a **"dynamodb_table is deprecated"** warning. That's expected: newer
> Terraform can lock in S3 itself (`use_lockfile = true`). DynamoDB locking still works.

## Adding another environment

Copy this folder to `environments/staging`, change `key` in `backend.tf` to
`staging/terraform.tfstate`, and set `environment = "staging"` in `terraform.tfvars`.

## Destroy

1. Set `deletion_protection = false` in `terraform.tfvars` and run `terraform apply`.
2. Run `terraform destroy`.
