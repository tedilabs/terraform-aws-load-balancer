output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_lb_listener.this.region
}

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

output "default_action" {
  description = "The default action for traffic on this listener."
  value = {
    type = var.default_action_type
    forward = (var.default_action_type == "FORWARD"
      ? {
        target_group = [
          for target in [var.default_action_parameters.target_group] : {
            arn  = target
            name = split("/", target)[1]
          }
        ][0]
      }
      : null
    )
    weighted_forward = (var.default_action_type == "WEIGHTED_FORWARD"
      ? {
        targets = [
          for target in var.default_action_parameters.targets : {
            target_group = {
              arn  = target.target_group
              name = split("/", target.target_group)[1]
            }
            weight = target.weight
          }
        ]
        stickiness = {
          enabled  = element(aws_lb_listener.this.default_action, -1).forward[0].stickiness[0].enabled
          duration = element(aws_lb_listener.this.default_action, -1).forward[0].stickiness[0].duration
        }
      }
      : null
    )
  }
}

output "tcp_idle_timeout" {
  description = "The number of seconds before the listener determines that the TCP connection is idle and closes it."
  value       = aws_lb_listener.this.tcp_idle_timeout_seconds
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
#     listener = {
#       for k, v in aws_lb_listener.this :
#       k => v
#       if !contains(["region", "load_balancer_arn", "port", "protocol", "timeouts", "tags", "tags_all", "id", "arn", "name", "routing_http_response_content_security_policy_header_value", "routing_http_response_x_content_type_options_header_value", "routing_http_response_x_frame_options_header_value", "routing_http_response_access_control_allow_origin_header_value", "routing_http_response_access_control_allow_methods_header_value", "routing_http_response_access_control_allow_headers_header_value", "routing_http_response_access_control_allow_credentials_header_value", "routing_http_response_access_control_expose_headers_header_value", "routing_http_response_access_control_max_age_header_value", "routing_http_response_server_enabled", "routing_http_response_strict_transport_security_header_value", "routing_http_request_x_amzn_tls_version_header_name", "routing_http_request_x_amzn_tls_cipher_suite_header_name", "routing_http_request_x_amzn_mtls_clientcert_header_name", "routing_http_request_x_amzn_mtls_clientcert_serial_number_header_name", "routing_http_request_x_amzn_mtls_clientcert_issuer_header_name", "routing_http_request_x_amzn_mtls_clientcert_subject_header_name", "routing_http_request_x_amzn_mtls_clientcert_validity_header_name", "routing_http_request_x_amzn_mtls_clientcert_leaf_header_name", "alpn_policy", "certificate_arn", "mutual_authentication", "ssl_policy", "tcp_idle_timeout_seconds"], k)
#     }
#   }
# }
