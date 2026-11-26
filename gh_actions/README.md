# gh_actions — CI for the Terraform code

Automatic checks that run on GitHub for every pull request and every push to `main`.

## How it's split

| File | Role |
|------|------|
| [`../.github/workflows/terraform-ci.yml`](../.github/workflows/terraform-ci.yml) | **When** to run and **on which folders**. GitHub only runs workflows from `.github/workflows/`, so this file has to live there |
| [`terraform-check/action.yml`](terraform-check/action.yml) | **What** to run: `fmt -check`, `init -backend=false`, `validate` for one folder |

The workflow runs the action once per stack, in parallel:
`bootstrap`, `management`, `dev`, `prod`.

## What it checks (and what it doesn't)

| Check | Catches |
|-------|---------|
| `terraform fmt -check` | Code that isn't formatted the standard way |
| `terraform validate` | Syntax errors, typos in names, wrong types, missing variables in references |

It does **not** connect to AWS: no credentials, no state, no `plan`. It's safe to run on any
pull request.

## Run the same checks locally

```bash
cd terraform/environments/dev
terraform fmt -check -recursive   # or: terraform fmt -recursive  (to fix)
terraform init -backend=false
terraform validate
```

## Good practices used

- **Third-party actions pinned to a commit SHA**, with the version in a comment. A tag can be
  moved to point at other code. A SHA can't.
- **`permissions: contents: read`**: the GitHub token can only read the repo.
- **`persist-credentials: false`**: the token isn't left behind in the checked-out repo.
- **`concurrency`**: a new push cancels the outdated run.
- **`paths` filter**: changes unrelated to Terraform or CI don't trigger runs.

## Make it required (GitHub settings)

**Settings → Branches → Add rule for `main`** → turn on "Require status checks to pass" and
select the four `terraform/...` checks. Now a pull request can't be merged if a check fails.

## Next steps

- `terraform plan` on pull requests, with AWS access through **OIDC** (no stored keys)
- `tflint` and `checkov` / `trivy` for linting and security scanning
