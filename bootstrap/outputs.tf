# Outputs are printed after `apply` and can be shown again with `terraform output`.

output "state_bucket_name" {
  description = "Name of the S3 bucket that stores Terraform state."
  value       = module.state_bucket.s3_bucket_id
}

output "state_bucket_arn" {
  description = "ARN of the state bucket."
  value       = module.state_bucket.s3_bucket_arn
}

output "lock_table_name" {
  description = "Name of the DynamoDB table used for state locking."
  value       = module.lock_table.dynamodb_table_id
}

output "lock_table_arn" {
  description = "ARN of the lock table."
  value       = module.lock_table.dynamodb_table_arn
}

# Ready-to-paste content for environments/<env>/backend.hcl
# Show it with:  terraform output -raw backend_hcl
output "backend_hcl" {
  description = "Copy this into environments/<env>/backend.hcl"
  value       = <<-EOT
    bucket         = "${module.state_bucket.s3_bucket_id}"
    region         = "${var.aws_region}"
    dynamodb_table = "${module.lock_table.dynamodb_table_id}"
    encrypt        = true
  EOT
}
