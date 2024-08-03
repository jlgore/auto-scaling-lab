output "id" {
  description = "ID of the launch template"
  value       = aws_launch_template.this.id
}

output "latest_version" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.this.latest_version
}

output "arn" {
  description = "ARN of the launch template"
  value       = aws_launch_template.this.arn
}