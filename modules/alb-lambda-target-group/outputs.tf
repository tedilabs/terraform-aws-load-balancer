output "arn" {
  description = "The Amazon Resource Name (ARN) of the target group."
  value       = aws_lb_target_group.this.arn
}

output "arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics."
  value       = aws_lb_target_group.this.arn_suffix
}

output "id" {
  description = "The ID of the target group."
  value       = aws_lb_target_group.this.id
}

output "name" {
  description = "The name of the target group."
  value       = aws_lb_target_group.this.name
}

output "type" {
  description = "The target type of the target group."
  value       = upper(aws_lb_target_group.this.target_type)
}

output "targets" {
  description = "A list of targets in the target group. The Lambda target group is limited to a single Lambda function target."
  value = [
    for target in aws_lb_target_group_attachment.this : {
      lambda_function = {
        arn = target.target_id
      }
    }
  ]
}

output "attributes" {
  description = "Attributes of the Lambda target group of application load balancer."
  value = {
    multi_value_headers_enabled = aws_lb_target_group.this.lambda_multi_value_headers_enabled
  }
}

output "health_check" {
  description = "Health Check configuration of the target group."
  value = {
    enabled = aws_lb_target_group.this.health_check[0].enabled

    healthy_threshold   = aws_lb_target_group.this.health_check[0].healthy_threshold
    unhealthy_threshold = aws_lb_target_group.this.health_check[0].unhealthy_threshold
    interval            = aws_lb_target_group.this.health_check[0].interval
    timeout             = aws_lb_target_group.this.health_check[0].timeout

    success_codes = aws_lb_target_group.this.health_check[0].matcher
    path          = aws_lb_target_group.this.health_check[0].path
  }
}
