# File: modules/auto_scaling/main.tf

resource "aws_autoscaling_group" "this" {
  name                = var.name
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.target_group_arns
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity

  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "this" {
  count                  = var.scaling_policy != "" ? 1 : 0
  name                   = "${var.name}-${var.scaling_policy}-policy"
  autoscaling_group_name = aws_autoscaling_group.this.name

  dynamic "target_tracking_configuration" {
    for_each = var.scaling_policy == "target_tracking" ? [1] : []
    content {
      predefined_metric_specification {
        predefined_metric_type = var.target_tracking_metric
      }
      target_value = var.target_tracking_target
    }
  }

  dynamic "step_adjustment" {
    for_each = var.scaling_policy == "step" ? var.step_scaling_adjustments : []
    content {
      scaling_adjustment          = step_adjustment.value.scaling_adjustment
      metric_interval_lower_bound = step_adjustment.value.metric_interval_lower_bound
      metric_interval_upper_bound = step_adjustment.value.metric_interval_upper_bound
    }
  }

  adjustment_type = var.scaling_policy == "simple" ? "ChangeInCapacity" : null
  cooldown        = var.scaling_policy == "simple" ? var.simple_scaling_cooldown : null
  policy_type     = var.scaling_policy == "target_tracking" ? "TargetTrackingScaling" : var.scaling_policy == "step" ? "StepScaling" : "SimpleScaling"

  # Only set scaling_adjustment for simple scaling policy
  scaling_adjustment = var.scaling_policy == "simple" ? var.simple_scaling_adjustment : null
}
