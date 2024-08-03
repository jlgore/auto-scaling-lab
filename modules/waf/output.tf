# File: modules/waf/outputs.tf

output "web_acl_id" {
  description = "The ID of the WAF Web ACL"
  value       = aws_wafv2_web_acl.this.id
}

output "web_acl_arn" {
  description = "The ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.this.arn
}

output "web_acl_capacity" {
  description = "The capacity of the WAF Web ACL"
  value       = aws_wafv2_web_acl.this.capacity
}

output "ip_set_arns" {
  description = "The ARNs of the IP sets"
  value       = { for k, v in aws_wafv2_ip_set.this : k => v.arn }
}