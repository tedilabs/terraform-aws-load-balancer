output "arn" {
  description = "The Amazon Resource Name (ARN) of the load balancer."
  value       = aws_lb.this.arn
}

output "arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics."
  value       = aws_lb.this.arn_suffix
}

output "id" {
  description = "The ID of the load balancer."
  value       = aws_lb.this.id
}

output "name" {
  description = "The name of the load balancer."
  value       = aws_lb.this.name
}

output "type" {
  description = "The type of the load balancer. Always return `GATEWAY`."
  value       = local.load_balancer_type
}

output "availability_zone_ids" {
  description = "A list of the Availability Zone IDs which are used by the load balancer."
  value       = local.availability_zone_ids
}

output "available_availability_zone_ids" {
  description = "A list of the Availability Zone IDs available to the current account and region."
  value       = local.available_availability_zone_ids
}

output "vpc_id" {
  description = "The VPC ID of the load balancer."
  value       = aws_lb.this.vpc_id
}

output "subnets" {
  description = "A list of subnet IDs attached to the load balancer."
  value       = aws_lb.this.subnets
}

output "network_mapping" {
  description = "The configuration for the load balancer how routes traffic to targets in which subnets and IP address settings."
  value       = local.network_mapping
}

output "attributes" {
  description = "Load Balancer Attributes that applied to the gateway load balancer."
  value = {
    cross_zone_load_balancing_enabled = aws_lb.this.enable_cross_zone_load_balancing
    deletion_protection_enabled       = aws_lb.this.enable_deletion_protection
  }
}

output "listeners" {
  description = "Listeners of the load balancer."
  value = var.target_group != null ? {
    6081 = {
      id   = one(aws_lb_listener.this.*.id)
      arn  = one(aws_lb_listener.this.*.arn)
      name = "${var.name}/GENEVE:6081"

      port     = "6081"
      protocol = "GENEVE"

      type = "forward"
      target_group = {
        arn      = var.target_group
        name     = one(data.aws_lb_target_group.this.*.name)
        port     = one(data.aws_lb_target_group.this.*.port)
        protocol = one(data.aws_lb_target_group.this.*.protocol)
      }
    }
  } : {}
}
