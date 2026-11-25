# aws-infra — Terraform training project

A small AWS setup built with **Terraform registry modules** (`terraform-aws-modules/*`).

## What gets created

| Where | Resource | Purpose |
|-------|----------|---------|
| `bootstrap/` | S3 bucket | Stores the Terraform **remote state** |
| `bootstrap/` | DynamoDB table | **State locking** (stops two `apply`s running at once) |
| `environments/dev/` | S3 bucket | Storage for the **application** |
| `environments/dev/` | DynamoDB table | **Application data** |
| `environments/dev/` | IAM users + groups | `admin` (full access) and `developer` (limited access) |
| `environments/dev/` | IAM role + policies | Lets the app's compute service talk to the app S3 bucket and table |

## Folder layout

```
aws-infra/
├── bootstrap/            # Step 1: remote-state backend (uses LOCAL state)
├── environments/
│   └── dev/              # Step 2: app infrastructure (uses REMOTE state in S3)
└── docs/
    ├── iam.md            # Who can do what
    └── best-practices.md # The practices this repo follows, and why
```

## Why two separate stacks?

The state bucket must exist **before** Terraform can store state in it, so it
can't manage itself (a chicken-and-egg problem). `bootstrap/` is applied once with local
state. Everything else then uses the bucket it created.

## Quick start

Prerequisites: Terraform >= 1.10, AWS CLI configured (`aws sts get-caller-identity` works).

```bash
# 1. Create the state backend
cd bootstrap
cp terraform.tfvars.example terraform.tfvars
terraform init && terraform apply

# 2. Create the app infrastructure
cd ../environments/dev
cp terraform.tfvars.example terraform.tfvars
cp backend.hcl.example backend.hcl        # fill in values from step 1 output
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

Each folder has its own README with more detail.

## Cleaning up

Destroy in **reverse** order: `environments/dev` first, then `bootstrap`.
Resources are protected from accidental deletion, so read the "Destroy" section in each
README first.
