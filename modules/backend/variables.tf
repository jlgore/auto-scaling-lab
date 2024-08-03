# s3_backend/variables.tf

variable "region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "us-west-2"
}

variable "create_s3_bucket" {
  description = "Whether to create the S3 bucket"
  type        = bool
  default     = true
}

variable "create_dynamodb_table" {
  description = "Whether to create the DynamoDB table"
  type        = bool
  default     = true
}

variable "bucket_name" {
  description = "The name of the S3 bucket to store Terraform state"
  type        = string
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for Terraform state locking"
  type        = string
  default     = "terraform-state-locks"
}
