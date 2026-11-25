# Outputs are printed after `apply` and can be shown again with `terraform output`.

output "state_bucket_name" {
  description = "Name of the S3 bucket that stores Terraform state."
  value       = module.state_bucket.s3_bucket_id
}

output "state_bucket_arn" {
  description = "ARN of the state bucket."
  value       = module.state_bucket.s3_bucket_arn
}

# Ready-to-paste content for environments/<env>/backend.hcl
# Show it with:  terraform output -raw backend_hcl
output "backend_hcl" {
  description = "Copy this into environments/<env>/backend.hcl for the environment in this account."
  value       = <<-EOT
    bucket       = "${module.state_bucket.s3_bucket_id}"
    region       = "${var.aws_region}"
    profile      = "${var.aws_profile}"
    use_lockfile = true
    encrypt      = true
  EOT
}
