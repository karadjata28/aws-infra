# bootstrap — remote state backend

Creates the resources every other stack needs to store its state:

- **S3 bucket** `<project>-tfstate-<account-id>`: versioned, encrypted, private,
  HTTPS only. Old state versions expire after 90 days.
- **DynamoDB table** `<project>-tf-locks`: holds the lock while a `plan`/`apply` runs.
  It has deletion protection on.

## Files

| File | What's in it |
|------|--------------|
| `versions.tf` | Terraform and provider version pins |
| `providers.tf` | AWS provider and default tags |
| `variables.tf` | Inputs (region, project name, ...) |
| `main.tf` | The S3 bucket and DynamoDB modules |
| `outputs.tf` | Names and ARNs, plus a ready-made `backend.hcl` |

## Usage (run once per AWS account)

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply

# Print the backend config for the next step:
terraform output -raw backend_hcl
```

## About local state

This stack keeps its state in a local `terraform.tfstate` file, because the bucket
doesn't exist until this stack creates it. The file is git-ignored.
**Back it up.** If you lose it, the resources keep working, but you would have to run
`terraform import` before Terraform could manage them again.

Optional: once the bucket exists, you can move this state into it. Add a
`backend "s3"` block with `key = "bootstrap/terraform.tfstate"`, then run
`terraform init -migrate-state`.

## Destroy

Only do this after every environment has been destroyed.
1. Set `deletion_protection_enabled = false` in `main.tf` and run `terraform apply`.
2. Empty the bucket, including all object versions (in the S3 console, choose **Empty**).
3. Run `terraform destroy`.
