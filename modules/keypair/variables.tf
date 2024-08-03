# File: modules/keypair/variables.tf

variable "key_name" {
  description = "The name for the key pair"
  type        = string
}

variable "create_private_key" {
  description = "Whether to create a private key"
  type        = bool
  default     = true
}

variable "public_key" {
  description = "The public key material"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to the key pair"
  type        = map(string)
  default     = {}
}