# IAM — who can do what

## Overview

```
 PEOPLE (IAM users)                        SERVICES (IAM role)
 ──────────────────                        ───────────────────
 training-dev-admin                        Lambda (or EC2/ECS)
     │ member of                               │ assumes
     ▼                                         ▼
 training-dev-admins ── AdministratorAccess    training-dev-app ── app-data-readwrite
                                                                     │
 training-dev-developer                                              ▼
     │ member of                                          S3 app bucket + DynamoDB table
     ▼                                                    (read + write)
 training-dev-developers ── app-data-readonly ──► S3 app bucket + DynamoDB table (read only)
```

## Permissions

| Identity | Type | S3 app bucket | DynamoDB app table | Rest of AWS |
|----------|------|---------------|--------------------|-------------|
| `admin` | user (via group) | full | full | full |
| `developer` | user (via group) | list + read | describe + read | none |
| `app` role | role (for a service) | list, read, write, delete | read, write, delete items | none |

Both groups can also manage their **own** password, access keys and MFA.
If `enforce_mfa = true`, users can do nothing else until they set up MFA.

## Users vs roles

- **Users** are for people. They have long-term credentials (password and access keys).
- **Roles** are for services. A role has no stored credentials: the service gets
  temporary credentials when it assumes the role. Always use a role for applications.

## Getting credentials after `apply`

Terraform deliberately does **not** create passwords or access keys, because they would be
stored in plain text in the state file. Create them yourself instead:

```bash
# Console password (the user must change it at first sign-in)
aws iam create-login-profile --user-name training-dev-developer \
  --password '<temporary-password>' --password-reset-required

# Access key for the CLI (shown only once, so store it safely)
aws iam create-access-key --user-name training-dev-developer
```

Then sign in as the user and set up MFA under **Security credentials** in the IAM console.

## Using the app role

Point your compute at `app_role_arn` (from `terraform output`). For example, a Lambda
function's `role` argument. The function code can then call S3 and DynamoDB with
no keys in the code.
