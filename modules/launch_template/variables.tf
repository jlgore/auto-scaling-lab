variable "name_prefix" {
  description = "Prefix for the launch template name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "ID of the AMI to use"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to the launch template"
  type        = map(string)
  default     = {}
}


variable "key_name" {
  description = "Name of the EC2 key pair to use"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "user_data" {
  description = "User data script (base64 encoded)"
  type        = string
  default     = null
}