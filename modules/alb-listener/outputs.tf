output "arn" {
  description = "The Amazon Resource Name (ARN) of the listener."
  value       = aws_lb_listener.this.arn
}

output "id" {
  description = "The ID of the listener."
  value       = aws_lb_listener.this.id
}

output "name" {
  description = "The name of the listener."
  value       = local.metadata.name
}

output "port" {
  description = "The port number on which the listener of load balancer is listening."
  value       = aws_lb_listener.this.port
}

output "protocol" {
  description = "The protocol for connections of the listener."
  value       = aws_lb_listener.this.protocol
}

output "type" {
  description = "The action type for the listener."
  value       = "forward"
}

output "target_group" {
  description = "The target group of the listener to route traffic."
  value = {
    arn      = var.target_group
    name     = data.aws_lb_target_group.this.name
    port     = data.aws_lb_target_group.this.port
    protocol = data.aws_lb_target_group.this.protocol
  }
}

output "tls" {
  description = "TLS configurations of the listener."
  value = local.tls_enabled ? {
    certificate = aws_lb_listener.this.certificate_arn
    additional_certificates = [
      for certificate in values(aws_lb_listener_certificate.this) :
      certificate.certificate_arn
    ]
    security_policy = aws_lb_listener.this.ssl_policy
  } : null
}
