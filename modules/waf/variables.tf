variable "name" {
  description = "Name for the WAF WebACL"
  type        = string
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer to associate with the WAF WebACL"
  type        = string
}

variable "ip_sets" {
  description = "Map of IP set configurations"
  type = map(object({
    name        = string
    description = string
    ip_addresses = list(string)
  }))
  default = {}
}

variable "rules" {
  description = "List of WAF rule configurations"
  type = list(object({
    name     = string
    priority = number
    action   = string # "allow", "block", or "count"
    type     = string # "ip_set", "managed_rule_group", or "rate_based"
    ip_set_key = optional(string) # Required if type is "ip_set"
    managed_rule_name = optional(string) # Required if type is "managed_rule_group"
    rate_limit = optional(number) # Required if type is "rate_based"
  }))
  default = []
}