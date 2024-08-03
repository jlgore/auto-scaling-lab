resource "random_pet" "stack" {
  length = 2
  separator = "-"
}

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"  # Assuming you've placed your VPC code in a 'vpc' subdirectory under 'modules'

  vpc_cidr              = "10.0.0.0/16"
  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs  = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones    = ["us-east-1a", "us-east-1b"]
  enable_flow_log       = false
  vpc_name              = "${random_pet.stack.id}-vpc"
}

module "ec2_key_pair" {
  source = "./modules/keypair"
  key_name = "${random_pet.stack.id}-key"
  create_private_key = true
  tags = {
    Environment = "dev"
    Project = random_pet.stack.id
  }
}

# Security Group for EC2 instances
resource "aws_security_group" "web_sg" {
  name        = "${random_pet.stack.id}-sg"
  description = "Security group for ${random_pet.stack.id} stack"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "web_server_launch_template" {
  source      = "./modules/launch_template"
  name_prefix = "web-server-${random_pet.stack.id}"
  instance_type = "t2.micro"
  ami_id      = data.aws_ssm_parameter.amazon_linux_2023.value
  key_name    = module.ec2_key_pair.key_name
  security_group_ids = [aws_security_group.web_sg.id]
  user_data = base64encode(<<-EOF
#!/bin/bash
set -e

# Update and install packages
dnf update -y
dnf install -y httpd

# Start and enable Apache
systemctl enable --now httpd

#dnf swap libcurl-minimal libcurl-full
#dnf swap curl-minimal curl-full

# Function to get IMDSv2 token
get_imdsv2_token() {
  curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -s
}

# Function to get metadata
get_metadata() {
  local metadata_path=$1
  local token=$(get_imdsv2_token)
  curl -H "X-aws-ec2-metadata-token: $token" -s "http://169.254.169.254/latest/meta-data/$metadata_path"
}

# Fetch instance metadata
INSTANCE_ID=$(get_metadata "instance-id")
AVAILABILITY_ZONE=$(get_metadata "placement/availability-zone")

# Create HTML content
cat <<HTML > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EC2 Instance Info</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-color: #f0f0f0;
        }
        .container {
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        h1 { color: #333; }
        p { color: #666; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Hello from EC2 Instance</h1>
        <p><strong>Instance ID:</strong> $${INSTANCE_ID}</p>
        <p><strong>Availability Zone:</strong> $${AVAILABILITY_ZONE}</p>
    </div>
</body>
</html>
HTML

# Ensure correct permissions
chown apache:apache /var/www/html/index.html
chmod 644 /var/www/html/index.html

# Test Apache
systemctl is-active --quiet httpd || (echo "Apache is not running. Starting it now..."; systemctl start httpd)

echo "Setup completed successfully!"
EOF
  )
  tags = {
    "key" = "name"
    "value" = "web-server-${random_pet.stack.id}"
  }
}

# ALB Module
module "web_alb" {
  source = "./modules/alb"

  name               = "web-alb-${random_pet.stack.id}"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [aws_security_group.web_sg.id]

  target_groups = [
    {
      name     = "web-tg"
      port     = 80
      protocol = "HTTP"
      health_check = {
        path                = "/"
        healthy_threshold   = 2
        unhealthy_threshold = 10
        timeout             = 5
        interval            = 30
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Name = "web-alb-${random_pet.stack.id}"
  }
}

# Auto Scaling Module w/Target Tracking
   module "web_auto_scaling" {
     source = "./modules/auto_scaling"
     name = "web-asg-${random_pet.stack.id}"
     vpc_id = module.vpc.vpc_id
     subnet_ids = module.vpc.public_subnet_ids
     target_group_arns = [module.web_alb.target_group_arns[0]]
     launch_template_id = module.web_server_launch_template.id
     min_size = 1
     max_size = 5
     desired_capacity = 2
     scaling_policy = "target_tracking"
     target_tracking_metric = "ASGAverageCPUUtilization"
     target_tracking_target = 50
   }
   

# module "web_waf" {
#   source = "./modules/waf"
  
#   name    = "web-waf-${random_pet.stack.id}"
#   alb_arn = module.web_alb.alb_arn

#   ip_sets = {
#     allowed_ips = {
#       name         = "allowed-ips"
#       description  = "Allowed IP addresses"
#       ip_addresses = ["192.0.2.0/24", "198.51.100.0/24"]
#     }
#   }

#   rules = [
#     {
#       name     = "allow-specific-ips"
#       priority = 1
#       action   = "allow"
#       type     = "ip_set"
#       ip_set_key = "allowed_ips"
#     },
#     {
#       name     = "limit-requests-per-ip"
#       priority = 2
#       action   = "count"
#       type     = "rate_based"
#       rate_limit = 100
#     }
#   ]
# }

# Outputs
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_dns_name" {
  value = module.web_alb.alb_dns_name
}

output "asg_name" {
  value = module.web_auto_scaling.asg_name
}

# output "waf_web_acl_id" {
#   value = module.web_waf.web_acl_id
# }

