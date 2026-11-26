# terraform — AWS infrastructure

A small multi-account AWS setup built with **Terraform registry modules**
(`terraform-aws-modules/*`). Each environment lives in its **own AWS account**, the way
real companies separate dev from prod.

## Accounts

| AWS account | Terraform folder | CLI profile | What lives there |
|-------------|------------------|-------------|------------------|
| Management | `environments/management` | `management` | Billing, the $20/month budget, SSO. **No applications** |
| Develop | `environments/dev` | `default` | The dev environment |
| Production | `environments/prod` | `production` | The prod environment |

## What gets created

| Where | Resource | Purpose |
|-------|----------|---------|
| `bootstrap/` (in every account) | S3 bucket | Stores that account's Terraform **remote state** (S3-native locking) |
| `environments/management/` | Budget + budget action + IAM role | Org-wide $20/month limit, email alerts, automatic block at 90% |
| `environments/<env>/` | S3 bucket | Storage for the **application** |
| `environments/<env>/` | DynamoDB table | **Application data** |
| `environments/<env>/` | IAM role + policy | Lets the app's compute service talk to the app S3 bucket and table |

`<env>` is `dev` or `prod`. Both use the **same code** with different values in
`terraform.tfvars`. People don't get IAM users: they sign in through SSO (see
[docs/iam.md](docs/iam.md)).

## Folder layout

```
terraform/
├── bootstrap/            # Step 1: state bucket, once per account (LOCAL state, one workspace per account)
├── environments/
│   ├── management/       # Step 2: budget and org settings  -> Management account
│   ├── dev/              # Step 3: app infrastructure        -> Develop account
│   └── prod/             # Step 4: same code, prod values    -> Production account
└── docs/
    ├── iam.md            # Who can do what
    └── best-practices.md # The practices this repo follows, and why
```

## Safety nets

- Every provider has `allowed_account_ids`: if your profile is logged into the wrong
  account, Terraform stops before it changes anything.
- Each account has its own state bucket, so a mistake in dev can't touch prod's state.
- Real account IDs and emails live only in `*.tfvars` and `backend.hcl`, which are git-ignored.

## Why a separate bootstrap stack?

The state bucket must exist **before** Terraform can store state in it, so it
can't manage itself (a chicken-and-egg problem). `bootstrap/` is applied once per account
with local state. Everything else then uses the bucket it created in its own account.

## Quick start

Prerequisites: the Terraform version in [`../.terraform-version`](../.terraform-version)
(`tfenv install` or `tfswitch` picks it up automatically), AWS CLI profiles `default`, `management` and
`production` working (`aws sts get-caller-identity --profile <name>`).

```bash
# 1. State bucket in each account (see bootstrap/README.md)
cd bootstrap
terraform init
terraform workspace new develop && terraform apply -var-file=develop.tfvars
# ...same for management and production

# 2. Management settings (imports the existing budget, creates nothing)
cd ../environments/management
terraform init -backend-config=backend.hcl
terraform plan

# 3. Dev, then prod once dev works
cd ../dev
terraform init -backend-config=backend.hcl
terraform plan
```

Each folder has its own README with the details.

## Cleaning up

Destroy in **reverse** order: `environments/prod` and `environments/dev` first, then
`bootstrap` in each account. Resources are protected from accidental deletion, so read
the "Destroy" section in each README first. Don't destroy `environments/management`:
it removes your spending limit.
