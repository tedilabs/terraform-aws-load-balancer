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

output "vpc_id" {
  description = "The ID of the VPC which the target group belongs to."
  value       = aws_lb_target_group.this.vpc_id
}

output "type" {
  description = "The target type of the target group."
  value       = upper(aws_lb_target_group.this.target_type)
}

output "protocol" {
  description = "The protocl to use to connect with the target."
  value       = aws_lb_target_group.this.protocol
}

output "port" {
  description = "The port number on which the target receive trrafic."
  value       = aws_lb_target_group.this.port
}

output "target_alb" {
  description = "The Amazon Resource Name (ARN) of the target ALB."
  value       = one(aws_lb_target_group_attachment.this.*.target_id)
}

output "test" {
  description = "The port number on which target alb receive trrafic."
  value = {
    for key, value in aws_lb_target_group.this :
    key => value
    if !contains(["arn", "arn_suffix", "vpc_id", "target_type", "port", "protocol", "tags", "tags_all", "deregistration_delay", "lambda_multi_value_headers_enabled", "preserve_client_ip", "id", "name"], key)
  }
}
