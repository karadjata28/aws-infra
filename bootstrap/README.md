# bootstrap — remote state backend (one bucket per account)

Creates the S3 bucket where every other stack stores its state. It runs **once in each
AWS account**, so each account keeps its own state:

| Account | Bucket | Used by |
|---------|--------|---------|
| Management | `training-tfstate-<management-id>` | `environments/management` |
| Develop | `training-tfstate-<develop-id>` | `environments/dev` |
| Production | `training-tfstate-<production-id>` | `environments/prod` |

The bucket is versioned, encrypted, private and HTTPS only. Old state versions expire
after 90 days. Locking uses S3 itself (`use_lockfile = true`), so there is no DynamoDB table.

## Files

| File | What's in it |
|------|--------------|
| `versions.tf` | Terraform and provider version pins |
| `providers.tf` | AWS provider, profile, account guard and default tags |
| `variables.tf` | Inputs (profile, account ID, region, project name, ...) |
| `main.tf` | The S3 bucket module |
| `outputs.tf` | Bucket name and ARN, plus a ready-made `backend.hcl` |
| `terraform.tfvars.example` | Template for the per-account values files |

## Usage (once per account)

One folder serves three accounts. A **workspace** keeps a separate local state file for
each one (`terraform.tfstate.d/<workspace>/`), and a values file says which account to use.

```bash
terraform init

# Repeat for management, develop and production:
cp terraform.tfvars.example develop.tfvars        # then fill in profile + account ID
terraform workspace new develop                    # or: terraform workspace select develop
terraform plan  -var-file=develop.tfvars
terraform apply -var-file=develop.tfvars

# Print the backend config for environments/dev:
terraform output -raw backend_hcl
```

If the profile is logged into a different account than `aws_account_id`, Terraform stops
with an error before it changes anything.

## About local state

This stack keeps its state locally in `terraform.tfstate.d/`, because the bucket doesn't
exist until this stack creates it. The folder is git-ignored.
**Back it up.** If you lose it, the buckets keep working, but you would have to run
`terraform import` before Terraform could manage them again.

## Destroy

Only do this after every environment in that account has been destroyed.
1. Empty the bucket, including all object versions (in the S3 console, choose **Empty**).
2. Run `terraform destroy -var-file=<account>.tfvars` in that account's workspace.
