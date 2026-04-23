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
  value = (local.tls_enabled
    ? {
      certificate = aws_lb_listener.this.certificate_arn
      additional_certificates = [
        for certificate in values(aws_lb_listener_certificate.this) :
        certificate.certificate_arn
      ]
      security_policy = aws_lb_listener.this.ssl_policy
    }
    : null
  )
}

output "mtls" {
  description = "The mTLS configurations of the listener."
  value = {
    mode = var.mtls.mode
    trust_store = (var.mtls.mode == "VERIFY"
      ? aws_lb_listener.this.mutual_authentication[0].trust_store_arn
      : null
    )
    ignore_client_certificate_expiry = (var.mtls.mode == "VERIFY"
      ? aws_lb_listener.this.mutual_authentication[0].ignore_client_certificate_expiry
      : null
    )
    advertise_trust_store_ca_names = (var.mtls.mode == "VERIFY"
      ? aws_lb_listener.this.mutual_authentication[0].advertise_trust_store_ca_names
      : null
    )
  }
}

output "default_action" {
  description = "The default action for traffic on this listener. Default action apply to traffic that does not meet the conditions of rules on your listener."
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
    fixed_response = (var.default_action_type == "FIXED_RESPONSE"
      ? {
        status_code  = element(aws_lb_listener.this.default_action, -1).fixed_response[0].status_code
        content_type = element(aws_lb_listener.this.default_action, -1).fixed_response[0].content_type
        data         = element(aws_lb_listener.this.default_action, -1).fixed_response[0].message_body
      }
      : null
    )
    redirect = (contains(["REDIRECT_301", "REDIRECT_302"], var.default_action_type)
      ? {
        status_code = split("_", element(aws_lb_listener.this.default_action, -1).redirect[0].status_code)[1]
        protocol    = element(aws_lb_listener.this.default_action, -1).redirect[0].protocol
        host        = element(aws_lb_listener.this.default_action, -1).redirect[0].host
        port        = element(aws_lb_listener.this.default_action, -1).redirect[0].port
        path        = element(aws_lb_listener.this.default_action, -1).redirect[0].path
        query       = element(aws_lb_listener.this.default_action, -1).redirect[0].query
        url = format(
          "%s://%s:%s%s?%s",
          lower(element(aws_lb_listener.this.default_action, -1).redirect[0].protocol),
          element(aws_lb_listener.this.default_action, -1).redirect[0].host,
          element(aws_lb_listener.this.default_action, -1).redirect[0].port,
          element(aws_lb_listener.this.default_action, -1).redirect[0].path,
          element(aws_lb_listener.this.default_action, -1).redirect[0].query,
        )
      }
      : null
    )
  }
}

locals {
  output_rules = {
    for rule in var.rules :
    rule.priority => {
      conditions = rule.conditions
      action = {
        type           = rule.action_type
        parameters     = rule.action_parameters
        forward        = try(aws_lb_listener_rule.this[rule.priority].action[0].forward[0], null)
        fixed_response = try(aws_lb_listener_rule.this[rule.priority].action[0].fixed_response[0], null)
        redirect       = try(aws_lb_listener_rule.this[rule.priority].action[0].redirect[0], null)
      }
      transforms = try(rule.transforms, [])
    }
  }
}

output "rules" {
  description = "The rules of the listener determine how the load balancer routes requests to the targets in one or more target groups."
  value = {
    for priority, rule in local.output_rules :
    priority => {
      conditions = rule.conditions
      action = {
        type = rule.action.type
        forward = (rule.action.type == "FORWARD"
          ? {
            target_group = {
              arn  = rule.action.parameters.target_group
              name = split("/", rule.action.parameters.target_group)[1]
            }
          }
          : null
        )
        weighted_forward = (rule.action.type == "WEIGHTED_FORWARD"
          ? {
            targets = [
              for target in rule.action.parameters.targets : {
                target_group = {
                  arn  = target.target_group
                  name = split("/", target.target_group)[1]
                }
                weight = try(target.weight, 1)
              }
            ]
            stickiness = {
              enabled  = rule.action.forward.stickiness[0].enabled
              duration = rule.action.forward.stickiness[0].duration
            }
          }
          : null
        )
        fixed_response = (rule.action.type == "FIXED_RESPONSE"
          ? {
            status_code  = rule.action.fixed_response.status_code
            content_type = rule.action.fixed_response.content_type
            data         = rule.action.fixed_response.message_body
          }
          : null
        )
        redirect = (contains(["REDIRECT_301", "REDIRECT_302"], rule.action.type)
          ? {
            status_code = split("_", rule.action.redirect.status_code)[1]
            protocol    = rule.action.redirect.protocol
            host        = rule.action.redirect.host
            port        = rule.action.redirect.port
            path        = rule.action.redirect.path
            query       = rule.action.redirect.query
            url = format(
              "%s://%s:%s%s?%s",
              lower(rule.action.redirect.protocol),
              rule.action.redirect.host,
              rule.action.redirect.port,
              rule.action.redirect.path,
              rule.action.redirect.query,
            )
          }
          : null
        )
      }
      transforms = rule.transforms
    }
  }
}

output "overwrite_response_headers" {
  description = "The overwrite response headers of the listener."
  value = {
    strict_transport_security = aws_lb_listener.this.routing_http_response_strict_transport_security_header_value
    content_security_policy   = aws_lb_listener.this.routing_http_response_content_security_policy_header_value
    x_content_type_options    = aws_lb_listener.this.routing_http_response_x_content_type_options_header_value
    x_frame_options           = aws_lb_listener.this.routing_http_response_x_frame_options_header_value
    cors = {
      allow_origins     = aws_lb_listener.this.routing_http_response_access_control_allow_origin_header_value
      allow_methods     = aws_lb_listener.this.routing_http_response_access_control_allow_methods_header_value
      allow_headers     = aws_lb_listener.this.routing_http_response_access_control_allow_headers_header_value
      allow_credentials = aws_lb_listener.this.routing_http_response_access_control_allow_credentials_header_value
      expose_headers    = aws_lb_listener.this.routing_http_response_access_control_expose_headers_header_value
      max_age           = aws_lb_listener.this.routing_http_response_access_control_max_age_header_value
    }
  }
}

output "server_response_header_enabled" {
  description = "Whether to include the server response header in the response of the listener."
  value       = aws_lb_listener.this.routing_http_response_server_enabled
}

output "rename_mtls_request_headers" {
  description = "The renamed mutual TLS client-certificate request headers of the listener. Only renamed headers are included; headers not specified in `var.rename_mtls_request_headers` are omitted."
  value = {
    for k, v in {
      "X-Amzn-Mtls-Clientcert"               = aws_lb_listener.this.routing_http_request_x_amzn_mtls_clientcert_header_name
      "X-Amzn-Mtls-Clientcert-Serial-Number" = aws_lb_listener.this.routing_http_request_x_amzn_mtls_clientcert_serial_number_header_name
      "X-Amzn-Mtls-Clientcert-Issuer"        = aws_lb_listener.this.routing_http_request_x_amzn_mtls_clientcert_issuer_header_name
      "X-Amzn-Mtls-Clientcert-Subject"       = aws_lb_listener.this.routing_http_request_x_amzn_mtls_clientcert_subject_header_name
      "X-Amzn-Mtls-Clientcert-Validity"      = aws_lb_listener.this.routing_http_request_x_amzn_mtls_clientcert_validity_header_name
      "X-Amzn-Mtls-Clientcert-Leaf"          = aws_lb_listener.this.routing_http_request_x_amzn_mtls_clientcert_leaf_header_name
    } :
    k => v
    if v != null
  }
}

output "rename_tls_request_headers" {
  description = "The renamed TLS context request headers of the listener. Only renamed headers are included; headers not specified in `var.rename_tls_request_headers` are omitted."
  value = {
    for k, v in {
      "X-Amzn-Tls-Version"      = aws_lb_listener.this.routing_http_request_x_amzn_tls_version_header_name
      "X-Amzn-Tls-Cipher-Suite" = aws_lb_listener.this.routing_http_request_x_amzn_tls_cipher_suite_header_name
    } :
    k => v
    if v != null
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
#     listener = {
#       for k, v in aws_lb_listener.this :
#       k => v
#       if !contains(["region", "load_balancer_arn", "port", "protocol", "timeouts", "tags", "tags_all", "id", "arn", "name", "certificate_arn", "ssl_policy", "mutual_authentication", "alpn_policy", "tcp_idle_timeout_seconds", "routing_http_response_content_security_policy_header_value", "routing_http_response_x_content_type_options_header_value", "routing_http_response_x_frame_options_header_value", "routing_http_response_access_control_allow_origin_header_value", "routing_http_response_access_control_allow_methods_header_value", "routing_http_response_access_control_allow_headers_header_value", "routing_http_response_access_control_allow_credentials_header_value", "routing_http_response_access_control_expose_headers_header_value", "routing_http_response_access_control_max_age_header_value", "routing_http_response_server_enabled", "routing_http_response_strict_transport_security_header_value", "routing_http_request_x_amzn_tls_version_header_name", "routing_http_request_x_amzn_tls_cipher_suite_header_name", "routing_http_request_x_amzn_mtls_clientcert_header_name", "routing_http_request_x_amzn_mtls_clientcert_serial_number_header_name", "routing_http_request_x_amzn_mtls_clientcert_issuer_header_name", "routing_http_request_x_amzn_mtls_clientcert_leaf_header_name", "routing_http_request_x_amzn_mtls_clientcert_subject_header_name", "routing_http_request_x_amzn_mtls_clientcert_validity_header_name"], k)
#     }
#   }
# }
