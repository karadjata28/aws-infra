# Remote state in the Management account's own bootstrap bucket.
# The account-specific values are in backend.hcl:  terraform init -backend-config=backend.hcl
terraform {
  backend "s3" {
    key = "management/terraform.tfstate"
  }
}
