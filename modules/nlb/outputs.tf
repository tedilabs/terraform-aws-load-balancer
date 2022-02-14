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
  description = "The type of the load balancer. Always return `NETWORK`."
  value       = local.load_balancer_type
}

output "zone_id" {
  description = "The canonical hosted zone ID of the load balancer to be used in a Route 53 Alias record."
  value       = aws_lb.this.zone_id
}

output "domain" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.this.dns_name
}

output "is_public" {
  description = "Indicates whether the load balancer is public."
  value       = !aws_lb.this.internal
}

output "ip_address_type" {
  description = "The type of IP addresses used by the subnets for your load balancer."
  value       = upper(aws_lb.this.ip_address_type)
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

output "access_log" {
  description = "The configuration for access logs of the load balancer."
  value = {
    enabled       = var.access_log_enabled
    s3_bucket     = var.access_log_s3_bucket
    s3_key_prefix = var.access_log_s3_key_prefix
  }
}

output "attributes" {
  description = "Load Balancer Attributes that applied to the network load balancer."
  value = {
    cross_zone_load_balancing_enabled = aws_lb.this.enable_cross_zone_load_balancing
    deletion_protection_enabled       = aws_lb.this.enable_deletion_protection
  }
}

output "listeners" {
  description = "The listeners of the network load balancer."
  value       = module.listener
}
