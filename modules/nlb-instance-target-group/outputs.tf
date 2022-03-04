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

output "port" {
  description = "The port number on which the target receive trrafic."
  value       = aws_lb_target_group.this.port
}

output "protocol" {
  description = "The protocol to use to connect with the target."
  value       = aws_lb_target_group.this.protocol
}

output "targets" {
  description = "A set of targets in the target group."
  value = [
    for target in aws_lb_target_group_attachment.this : {
      instance = target.target_id
      port     = target.port
    }
  ]
}

output "attributes" {
  description = "Attributes of the Instance target group of network load balancer."
  value = {
    terminate_connection_on_deregistration = aws_lb_target_group.this.connection_termination
    deregistration_delay                   = aws_lb_target_group.this.deregistration_delay
    preserve_client_ip                     = aws_lb_target_group.this.preserve_client_ip
    proxy_protocol_v2                      = aws_lb_target_group.this.proxy_protocol_v2
    stickiness = {
      enabled = aws_lb_target_group.this.stickiness[0].enabled
      type    = upper(aws_lb_target_group.this.stickiness[0].type)
    }
  }
}

output "health_check" {
  description = "Health Check configuration of the target group."
  value = {
    protocol = aws_lb_target_group.this.health_check[0].protocol
    port     = aws_lb_target_group.this.health_check[0].port

    healthy_threshold   = aws_lb_target_group.this.health_check[0].healthy_threshold
    unhealthy_threshold = aws_lb_target_group.this.health_check[0].unhealthy_threshold
    interval            = aws_lb_target_group.this.health_check[0].interval
    timeout             = aws_lb_target_group.this.health_check[0].timeout

    success_codes = aws_lb_target_group.this.health_check[0].matcher
    path          = aws_lb_target_group.this.health_check[0].path
  }
}
