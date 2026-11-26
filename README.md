# aws-infra

A multi-account AWS setup written in **Terraform**, with **GitHub Actions** checking every
change automatically.

## Repository layout

```
aws-infra/
├── terraform/                 # All infrastructure code     -> terraform/README.md
│   ├── bootstrap/             #   state bucket, once per account
│   ├── environments/          #   management, dev, prod
│   └── docs/                  #   IAM and best-practice notes
├── gh_actions/                # CI logic (reusable action)  -> gh_actions/README.md
│   └── terraform-check/
├── .github/workflows/         # CI triggers (GitHub requires this exact folder)
│   └── terraform-ci.yml
└── .terraform-version         # Terraform version for EVERYONE: CI and local (tfenv/tfswitch)
```

To upgrade Terraform, change `.terraform-version` and nothing else.

| Folder | Start here |
|--------|------------|
| Infrastructure | [terraform/README.md](terraform/README.md) |
| CI/CD | [gh_actions/README.md](gh_actions/README.md) |

## How a change flows

```
branch -> commit -> pull request -> Terraform CI (fmt + validate) -> review -> merge to main
```

Infrastructure changes are applied with `terraform plan` / `apply` from each environment
folder (see [terraform/README.md](terraform/README.md)).
