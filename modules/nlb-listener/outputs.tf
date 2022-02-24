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

output "default_action" {
  description = "The default action for traffic on this listener."
  value = {
    type = "FORWARD"
    forward = {
      arn  = var.target_group
      name = split("/", var.target_group)[1]
    }
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
    alpn_policy     = aws_lb_listener.this.alpn_policy
  } : null
}
