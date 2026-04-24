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

output "ip_address_type" {
  description = "The type of IP addresses used by the target group."
  value       = upper(aws_lb_target_group.this.ip_address_type)
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
      ip_address  = target.target_id
      port        = target.port
      is_external = target.availability_zone == "all"
    }
  ]
}

output "attributes" {
  description = "Attributes of the IP target group of network load balancer."
  value = {
    on_deregistration = {
      connection_termination_enabled = aws_lb_target_group.this.connection_termination
      draining_interval              = tonumber(aws_lb_target_group.this.deregistration_delay)
    }
    on_unhealthy = {
      connection_termination_enabled = aws_lb_target_group.this.target_health_state[0].enable_unhealthy_connection_termination
      draining_interval              = tonumber(aws_lb_target_group.this.target_health_state[0].unhealthy_draining_interval)
    }
    load_balancing = {
      cross_zone_strategy = var.load_balancing.cross_zone_strategy
      stickiness = {
        enabled = aws_lb_target_group.this.stickiness[0].enabled
        type    = upper(aws_lb_target_group.this.stickiness[0].type)
      }
    }
    preserve_client_ip = aws_lb_target_group.this.preserve_client_ip
    proxy_protocol_v2  = aws_lb_target_group.this.proxy_protocol_v2
  }
}

output "dns_failover_condition" {
  description = "The configuration for DNS failover requirements."
  value = {
    min_healthy_targets = {
      count = (aws_lb_target_group.this.target_group_health[0].dns_failover[0].minimum_healthy_targets_count != "off"
        ? tonumber(aws_lb_target_group.this.target_group_health[0].dns_failover[0].minimum_healthy_targets_count)
        : 0
      )
      percentage = (aws_lb_target_group.this.target_group_health[0].dns_failover[0].minimum_healthy_targets_percentage != "off"
        ? tonumber(aws_lb_target_group.this.target_group_health[0].dns_failover[0].minimum_healthy_targets_percentage)
        : 0
      )
    }
  }
}

output "unhealthy_state_routing_condition" {
  description = "The configuration for unhealthy state routing requirements."
  value = {
    min_healthy_targets = {
      count = tonumber(aws_lb_target_group.this.target_group_health[0].unhealthy_state_routing[0].minimum_healthy_targets_count)
      percentage = (aws_lb_target_group.this.target_group_health[0].unhealthy_state_routing[0].minimum_healthy_targets_percentage != "off"
        ? tonumber(aws_lb_target_group.this.target_group_health[0].unhealthy_state_routing[0].minimum_healthy_targets_percentage)
        : 0
      )
    }
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
#       if !contains(["id", "arn", "arn_suffix", "name", "tags", "tags_all", "lambda_multi_value_headers_enabled", "target_type", "vpc_id", "port", "protocol", "health_check", "target_group_health", "target_failover", "ip_address_type", "load_balancer_arns", "region", "protocol_version", "name_prefix", "preserve_client_ip", "target_control_port", "load_balancing_algorithm_type", "load_balancing_anomaly_mitigation", "proxy_protocol_v2", "slow_start", "stickiness", "load_balancing_cross_zone_enabled", "deregistration_delay", "connection_termination", "target_health_state"], k)
#     }
#     targets = [
#       for target in aws_lb_target_group_attachment.this : {
#         for k, v in target :
#         k => v
#         if !contains(["region", "target_group_arn", "target_id", "port"], k)
#       }
#     ]
#   }
# }
