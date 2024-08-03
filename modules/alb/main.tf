# File: modules/alb/main.tf

resource "aws_lb" "this" {
  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = var.tags
}

resource "aws_lb_target_group" "this" {
  count    = length(var.target_groups)
  name     = var.target_groups[count.index].name
  port     = var.target_groups[count.index].port
  protocol = var.target_groups[count.index].protocol
  vpc_id   = var.vpc_id

  health_check {
    path                = var.target_groups[count.index].health_check.path
    healthy_threshold   = var.target_groups[count.index].health_check.healthy_threshold
    unhealthy_threshold = var.target_groups[count.index].health_check.unhealthy_threshold
    timeout             = var.target_groups[count.index].health_check.timeout
    interval            = var.target_groups[count.index].health_check.interval
  }

  tags = var.tags
}

resource "aws_lb_listener" "this" {
  count             = length(var.http_tcp_listeners)
  load_balancer_arn = aws_lb.this.arn
  port              = var.http_tcp_listeners[count.index].port
  protocol          = var.http_tcp_listeners[count.index].protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[var.http_tcp_listeners[count.index].target_group_index].arn
  }
}