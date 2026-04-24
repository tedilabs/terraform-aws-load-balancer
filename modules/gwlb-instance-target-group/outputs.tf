output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_lb_target_group.this.region
}

output "load_balancers" {
  description = "The ARNs (Amazon Resource Name) of the load balancers associated with the target group."
  value       = aws_lb_target_group.this.load_balancer_arns
}

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
  description = "Attributes of the Instance target group of gateway load balancer."
  value = {
    deregistration_delay = tonumber(aws_lb_target_group.this.deregistration_delay)
  }
}

output "target_failover" {
  description = "The configuration of target failover for the target group."
  value = {
    rebalance_on_deregistration = aws_lb_target_group.this.target_failover[0].on_deregistration == "rebalance"
    rebalance_on_unhealthy      = aws_lb_target_group.this.target_failover[0].on_unhealthy == "rebalance"
  }
}

output "flow_stickiness" {
  description = "The configuration of flow stickiness for the target group."
  value = {
    type = var.flow_stickiness.type
  }
}

output "health_check" {
  description = "Health Check configuration of the target group."
  value = {
    protocol      = aws_lb_target_group.this.health_check[0].protocol
    port          = aws_lb_target_group.this.health_check[0].port
    path          = aws_lb_target_group.this.health_check[0].path
    success_codes = aws_lb_target_group.this.health_check[0].matcher

    healthy_threshold   = aws_lb_target_group.this.health_check[0].healthy_threshold
    unhealthy_threshold = aws_lb_target_group.this.health_check[0].unhealthy_threshold
    interval            = aws_lb_target_group.this.health_check[0].interval
    timeout             = aws_lb_target_group.this.health_check[0].timeout
  }
}

output "resource_group" {
  description = "The resource group created to manage resources in this module."
  value = merge(
    {
      enabled = var.resource_group.enabled && var.module_tags_enabled
    },
    (var.resource_group.enabled && var.module_tags_enabled
      ? {
        arn  = module.resource_group[0].arn
        name = module.resource_group[0].name
      }
      : {}
    )
  )
}

# output "debug" {
#   value = {
#     target_group = {
#       for k, v in aws_lb_target_group.this :
#       k => v
#       if !contains(["id", "arn", "arn_suffix", "name", "tags", "tags_all", "region", "vpc_id", "target_type", "target_group_health", "target_control_port", "protocol", "protocol_version", "health_check", "port", "name_prefix", "load_balancer_arns", "lambda_multi_value_headers_enabled", "preserve_client_ip", "proxy_protocol_v2", "load_balancing_algorithm_type", "load_balancing_anomaly_mitigation", "load_balancing_cross_zone_enabled", "ip_address_type", "slow_start", "connection_termination", "deregistration_delay", "target_failover", "target_health_state", "stickiness"], k)
#     }
#     targets = [
#       for target in aws_lb_target_group_attachment.this : {
#         for k, v in target :
#         k => v
#         if !contains(["region", "target_group_arn", "target_id", "port", "quic_server_id"], k)
#       }
#     ]
#   }
# }
