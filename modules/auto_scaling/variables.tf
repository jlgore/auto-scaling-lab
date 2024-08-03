variable "name" {
  description = "Name for the Auto Scaling Group"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Auto Scaling Group"
  type        = list(string)
}

variable "target_group_arns" {
  description = "List of target group ARNs"
  type        = list(string)
}

variable "launch_template_id" {
  description = "ID of the launch template"
  type        = string
}

variable "min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
}

variable "max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
}

variable "desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
}

variable "scaling_policy" {
  description = "Type of scaling policy (simple, step, or target_tracking)"
  type        = string
}

variable "simple_scaling_adjustment" {
  description = "Number of instances to add or remove for simple scaling"
  type        = number
  default     = 1
}

variable "simple_scaling_cooldown" {
  description = "Cooldown period for simple scaling"
  type        = number
  default     = 300
}

variable "step_scaling_adjustments" {
  description = "List of step adjustments for step scaling"
  type = list(object({
    scaling_adjustment          = number
    metric_interval_lower_bound = number
    metric_interval_upper_bound = optional(number)
  }))
  default = []
}

variable "target_tracking_metric" {
  description = "Metric to use for target tracking scaling"
  type        = string
  default     = "ASGAverageCPUUtilization"
}

variable "target_tracking_target" {
  description = "Target value for the metric in target tracking scaling"
  type        = number
  default     = 50
}