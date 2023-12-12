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
  description = "The type of the load balancer. Always return `APPLICATION`."
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

output "default_security_group" {
  description = "The default security group ID of the load balancer."
  value       = one(module.security_group[*].id)
}

output "security_groups" {
  description = "A set of security group IDs which is assigned to the load balancer."
  value       = aws_lb.this.security_groups
}

output "access_log" {
  description = "The configuration for access logs of the load balancer."
  value       = var.access_log
}

output "attributes" {
  description = "Load Balancer Attributes that applied to the application load balancer."
  value = {
    cross_zone_load_balancing_enabled = aws_lb.this.enable_cross_zone_load_balancing
    desync_mitigation_mode            = upper(aws_lb.this.desync_mitigation_mode)
    deletion_protection_enabled       = aws_lb.this.enable_deletion_protection
    http2_enabled                     = aws_lb.this.enable_http2
    waf_fail_open_enabled             = aws_lb.this.enable_waf_fail_open
    idle_timeout                      = aws_lb.this.idle_timeout

    tls_negotiation_headers_enabled = aws_lb.this.enable_tls_version_and_cipher_suite_headers
    drop_invalid_header_fields      = aws_lb.this.drop_invalid_header_fields
    preserve_host_header            = aws_lb.this.preserve_host_header
    xff_header = {
      mode                             = upper(aws_lb.this.xff_header_processing_mode)
      client_port_preservation_enabled = aws_lb.this.enable_xff_client_port
    }
  }
}

output "listeners" {
  description = "The listeners of the application load balancer."
  value       = module.listener
}
