# --- Storage -----------------------------------------------------------------

output "app_bucket_name" {
  description = "Name of the application S3 bucket."
  value       = module.app_bucket.s3_bucket_id
}

output "app_bucket_arn" {
  description = "ARN of the application S3 bucket."
  value       = module.app_bucket.s3_bucket_arn
}

output "app_table_name" {
  description = "Name of the application DynamoDB table."
  value       = module.app_table.dynamodb_table_id
}

output "app_table_arn" {
  description = "ARN of the application DynamoDB table."
  value       = module.app_table.dynamodb_table_arn
}

# --- IAM ---------------------------------------------------------------------

output "admin_user_name" {
  description = "IAM user with full admin access."
  value       = module.admin_user.name
}

output "developer_user_name" {
  description = "IAM user with read-only access to the app data."
  value       = module.developer_user.name
}

output "app_role_arn" {
  description = "ARN of the role the app's compute service assumes."
  value       = module.app_role.arn
}

output "app_data_readwrite_policy_arn" {
  description = "ARN of the read/write app data policy."
  value       = module.app_data_readwrite_policy.arn
}

output "app_data_readonly_policy_arn" {
  description = "ARN of the read-only app data policy."
  value       = module.app_data_readonly_policy.arn
}
