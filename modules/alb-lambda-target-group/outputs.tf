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

output "target_lambda" {
  description = "The Amazon Resource Name (ARN) of the target Lambda."
  value       = one(aws_lb_target_group_attachment.this.*.target_id)
}

output "attributes" {
  description = "Attributes of the Lambda target group of application load balancer."
  value = {
    multi_value_headers_enabled = aws_lb_target_group.this.lambda_multi_value_headers_enabled
  }
}

output "test" {
  description = "The port number on which target alb receive trrafic."
  value = {
    for key, value in aws_lb_target_group.this :
    key => value
    if !contains(["arn", "arn_suffix", "vpc_id", "target_type", "port", "protocol", "tags", "tags_all", "deregistration_delay", "lambda_multi_value_headers_enabled", "preserve_client_ip", "id", "name", "connection_termination", "load_balancing_algorithm_type", "name_prefix", "protocol_version", "proxy_protocol_v2", "slow_start"], key)
  }
}
