# File: modules/alb/outputs.tf

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.this.dns_name
}

output "alb_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.this.arn
}

output "target_group_arns" {
  description = "List of target group ARNs"
  value       = aws_lb_target_group.this[*].arn
}