# File: modules/keypair/main.tf

resource "tls_private_key" "this" {
  count     = var.create_private_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "private_key" {
  count           = var.create_private_key ? 1 : 0
  content         = tls_private_key.this[0].private_key_pem
  filename        = "${path.module}/${var.key_name}.pem"
  file_permission = "0600"
}

resource "aws_key_pair" "this" {
  key_name   = var.key_name
  public_key = var.create_private_key ? tls_private_key.this[0].public_key_openssh : var.public_key
  tags       = var.tags
}