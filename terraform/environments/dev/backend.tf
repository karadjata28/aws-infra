# Remote state: this stack's state lives in the S3 bucket created by ../../bootstrap.
#
# This is a "partial configuration". Only the values that never change are written
# here. The account-specific values (bucket, region, lock table) are in backend.hcl
# and are passed in at init time:
#
#   terraform init -backend-config=backend.hcl
#
# (A backend block can't use variables, which is why it's split up like this.)
terraform {
  backend "s3" {
    # Path of the state file inside the bucket. Use a different key per environment.
    key = "dev/terraform.tfstate"
  }
}
