# s3_backend/outputs.tf

output "s3_bucket_name" {
  value       = var.create_s3_bucket ? aws_s3_bucket.terraform_state[0].id : var.bucket_name
  description = "The name of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = var.create_dynamodb_table ? aws_dynamodb_table.terraform_locks[0].id : var.dynamodb_table_name
  description = "The name of the DynamoDB table"
}