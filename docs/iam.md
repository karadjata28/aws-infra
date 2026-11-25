# IAM — who can do what

There are two kinds of identities, and they live in different places:

| Who | How they get access | Where it's defined |
|-----|--------------------|--------------------|
| **People** (you, teammates) | IAM Identity Center (SSO): sign in once, pick an account | Management account, managed by AWS's guided setup |
| **Applications** (Lambda, EC2, ECS) | An IAM **role** in their own account, with short-lived credentials | `environments/<env>/iam_roles.tf` |

There are **no IAM users** for people in this repo. SSO users get temporary credentials,
so there are no long-lived passwords or access keys to leak.

## People: SSO

```
 you ──sign in──► IAM Identity Center (Management account)
                     │
                     ├── group 607520121097-AdministratorAccess ──► Develop account
                     └── group 844153410920-AdministratorAccess ──► Production account
```

AWS's guided multi-account setup created these groups and keeps managing them. It also
turns off custom permission sets, which is why SSO access isn't written in Terraform here.
To give someone access, add them to the right group in the IAM Identity Center console.

For the CLI, log in with your browser instead of using access keys:

```bash
aws login --profile production   # opens a sign-in link, saves short-lived credentials
```

> The Develop `default` profile still uses the `terraform` IAM user's access key. It works,
> but long-lived keys are the main thing SSO removes. Once you're comfortable, switch it
> to `aws login` as well and delete that key.

## Applications: the app role

The examples use **dev** names. Prod creates the same set with `prod` in the name, in the
Production account.

```
 Lambda (or EC2/ECS)
     │ assumes
     ▼
 training-dev-app ── app-data-readwrite ──► S3 app bucket + DynamoDB table (read + write)
```

| Identity | S3 app bucket | DynamoDB app table | Rest of AWS |
|----------|---------------|--------------------|-------------|
| `app` role | list, read, write, delete | read, write, delete items | none |

Point your compute at `app_role_arn` (from `terraform output`), for example a Lambda
function's `role` argument. The function code can then call S3 and DynamoDB with
no keys in the code.

## Management account

The only IAM resource Terraform manages in Management is `BudgetsSpendLimitActionRole`.
AWS Budgets assumes it to block new paid resources when spending reaches the limit. It can
only attach and detach SCPs.
