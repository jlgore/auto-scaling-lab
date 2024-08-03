# File: modules/alb/variables.tf

variable "name" {
  description = "Name for the ALB and related resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the ALB"
  type        = list(string)
}

variable "target_groups" {
  description = "A list of target group configurations"
  type = list(object({
    name     = string
    port     = number
    protocol = string
    health_check = object({
      path                = string
      healthy_threshold   = number
      unhealthy_threshold = number
      timeout             = number
      interval            = number
    })
  }))
}

variable "http_tcp_listeners" {
  description = "A list of HTTP/HTTPS listener configurations"
  type = list(object({
    port               = number
    protocol           = string
    target_group_index = number
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}