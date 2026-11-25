# environments/prod — production infrastructure (Production account)

The prod environment. It is deployed into the **Production** AWS account, separate from
dev. The code is **the same as `dev/`**. Only the values in `terraform.tfvars`, the
backend bucket and the state `key` are different. Keeping the code identical means what
you tested in dev is exactly what runs in prod.

Its state is stored in the **Production account's own** bootstrap bucket at
`prod/terraform.tfstate`, so nothing in the Develop account can read or change it.

## How prod differs from dev

| Setting | dev | prod |
|---------|-----|------|
| AWS account | Develop | Production |
| CLI profile | `default` | `production` |
| State bucket | `training-tfstate-<develop-id>` | `training-tfstate-<production-id>` |
| State key | `dev/terraform.tfstate` | `prod/terraform.tfstate` |
| Resource names | `training-dev-*` | `training-prod-*` |
| Old file versions kept | 30 days | 90 days |
| Deletion protection | on (can turn off) | on (keep it on) |

For a description of each file, see [../dev/README.md](../dev/README.md). The files are the same.

## Usage

Run `../../bootstrap` for the Production account first. Log in before each session,
because the `production` profile uses short-lived credentials:

```bash
aws login --profile production

cp terraform.tfvars.example terraform.tfvars   # fill in the Production account ID
cp backend.hcl.example backend.hcl             # Production's own bucket, not dev's

terraform init -backend-config=backend.hcl
terraform plan -out=tfplan   # read it carefully
terraform apply tfplan
```

> Rule of thumb: change dev first, check that it works, then apply the same change to prod.

## Keeping dev and prod in sync

The `.tf` files should stay identical. After editing dev, check for differences:

```bash
diff -r --exclude=.terraform --exclude='*.tfvars*' --exclude='backend.hcl*' --exclude=backend.tf --exclude=README.md \
  ../dev .
```

(Later, a shared module in `modules/` removes the duplication completely.)

## Destroy

You normally **don't** destroy prod. If you really need to:
1. Set `deletion_protection = false` in `terraform.tfvars` and run `terraform apply`.
2. Run `terraform destroy`.
