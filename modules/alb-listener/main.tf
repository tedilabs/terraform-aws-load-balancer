locals {
  metadata = {
    package = "terraform-aws-load-balancer"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = "${local.load_balancer_name}/${var.protocol}:${var.port}"
  }
  module_tags = var.module_tags_enabled ? {
    "module.terraform.io/package"   = local.metadata.package
    "module.terraform.io/version"   = local.metadata.version
    "module.terraform.io/name"      = local.metadata.module
    "module.terraform.io/full-name" = "${local.metadata.package}/${local.metadata.module}"
    "module.terraform.io/instance"  = local.metadata.name
  } : {}
}

locals {
  load_balancer_name = split("/", var.load_balancer)[2]
  tls_enabled        = var.protocol == "HTTPS"

  rule_transform_type = {
    "HOST_HEADER_REWRITE" = "host-header-rewrite"
    "URL_REWRITE"         = "url-rewrite"
  }
}


###################################################
# ALB Listener
###################################################

# INFO: Not supported attributes
# - `alpn_policy` (NLB only)
# - `tcp_idle_timeout_seconds` (NLB & GWLB only)
# TODO: AUTHENTICATE_COGNITO / AUTHENTICATE_OIDC / JWT_VALIDATION action types
resource "aws_lb_listener" "this" {
  region = var.region

  load_balancer_arn = var.load_balancer

  port     = var.port
  protocol = var.protocol


  ## TLS
  certificate_arn = local.tls_enabled ? var.tls.certificate : null
  ssl_policy      = local.tls_enabled ? var.tls.security_policy : null

  dynamic "mutual_authentication" {
    for_each = var.mtls.mode != "OFF" ? [var.mtls] : []
    iterator = mtls

    content {
      mode                             = lower(mtls.value.mode)
      trust_store_arn                  = mtls.value.trust_store
      ignore_client_certificate_expiry = mtls.value.ignore_client_certificate_expiry
      advertise_trust_store_ca_names   = mtls.value.advertise_trust_store_ca_names ? "on" : "off"
    }
  }


  ## Actions
  dynamic "default_action" {
    for_each = (var.default_action_type == "FORWARD"
      ? [var.default_action_parameters]
      : []
    )

    content {
      type = "forward"

      target_group_arn = default_action.value.target_group
    }
  }

  dynamic "default_action" {
    for_each = (var.default_action_type == "WEIGHTED_FORWARD"
      ? [var.default_action_parameters]
      : []
    )

    content {
      type = "forward"

      forward {
        dynamic "target_group" {
          for_each = default_action.value.targets
          iterator = target

          content {
            arn    = target.value.target_group
            weight = target.value.weight
          }
        }
        stickiness {
          enabled  = default_action.value.stickiness_duration > 0
          duration = default_action.value.stickiness_duration
        }
      }
    }
  }

  dynamic "default_action" {
    for_each = (var.default_action_type == "FIXED_RESPONSE"
      ? [var.default_action_parameters]
      : []
    )

    content {
      type = "fixed-response"

      fixed_response {
        status_code  = default_action.value.status_code
        content_type = default_action.value.content_type
        message_body = default_action.value.data
      }
    }
  }

  dynamic "default_action" {
    for_each = (var.default_action_type == "REDIRECT_301"
      ? [var.default_action_parameters]
      : []
    )

    content {
      type = "redirect"

      redirect {
        status_code = "HTTP_301"
        protocol    = default_action.value.protocol
        host        = default_action.value.host
        port        = default_action.value.port
        path        = default_action.value.path
        query       = default_action.value.query
      }
    }
  }

  dynamic "default_action" {
    for_each = (var.default_action_type == "REDIRECT_302"
      ? [var.default_action_parameters]
      : []
    )

    content {
      type = "redirect"

      redirect {
        status_code = "HTTP_302"
        protocol    = default_action.value.protocol
        host        = default_action.value.host
        port        = default_action.value.port
        path        = default_action.value.path
        query       = default_action.value.query
      }
    }
  }


  ## Attributes
  # Response Headers (Overwrite)
  routing_http_response_strict_transport_security_header_value = var.overwrite_response_headers.strict_transport_security
  routing_http_response_content_security_policy_header_value   = var.overwrite_response_headers.content_security_policy
  routing_http_response_x_content_type_options_header_value    = var.overwrite_response_headers.x_content_type_options
  routing_http_response_x_frame_options_header_value           = var.overwrite_response_headers.x_frame_options

  routing_http_response_access_control_allow_origin_header_value      = var.overwrite_response_headers.cors.allow_origin
  routing_http_response_access_control_allow_methods_header_value     = var.overwrite_response_headers.cors.allow_methods
  routing_http_response_access_control_allow_headers_header_value     = var.overwrite_response_headers.cors.allow_headers
  routing_http_response_access_control_allow_credentials_header_value = var.overwrite_response_headers.cors.allow_credentials
  routing_http_response_access_control_expose_headers_header_value    = var.overwrite_response_headers.cors.expose_headers
  routing_http_response_access_control_max_age_header_value           = var.overwrite_response_headers.cors.max_age

  routing_http_response_server_enabled = var.server_response_header_enabled

  # Request Headers (Rename)
  routing_http_request_x_amzn_mtls_clientcert_header_name               = lookup(var.rename_mtls_request_headers, "X-Amzn-Mtls-Clientcert", null)
  routing_http_request_x_amzn_mtls_clientcert_serial_number_header_name = lookup(var.rename_mtls_request_headers, "X-Amzn-Mtls-Clientcert-Serial-Number", null)
  routing_http_request_x_amzn_mtls_clientcert_issuer_header_name        = lookup(var.rename_mtls_request_headers, "X-Amzn-Mtls-Clientcert-Issuer", null)
  routing_http_request_x_amzn_mtls_clientcert_leaf_header_name          = lookup(var.rename_mtls_request_headers, "X-Amzn-Mtls-Clientcert-Leaf", null)
  routing_http_request_x_amzn_mtls_clientcert_subject_header_name       = lookup(var.rename_mtls_request_headers, "X-Amzn-Mtls-Clientcert-Subject", null)
  routing_http_request_x_amzn_mtls_clientcert_validity_header_name      = lookup(var.rename_mtls_request_headers, "X-Amzn-Mtls-Clientcert-Validity", null)

  routing_http_request_x_amzn_tls_version_header_name      = lookup(var.rename_tls_request_headers, "X-Amzn-Tls-Version", null)
  routing_http_request_x_amzn_tls_cipher_suite_header_name = lookup(var.rename_tls_request_headers, "X-Amzn-Tls-Cipher-Suite", null)


  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}


###################################################
# Rules for Listener
###################################################

resource "aws_lb_listener_rule" "this" {
  for_each = {
    for rule in var.rules :
    rule.priority => rule
  }

  region = var.region

  listener_arn = aws_lb_listener.this.arn

  priority = each.key

  dynamic "condition" {
    for_each = try(each.value.conditions, [])

    content {
      dynamic "host_header" {
        for_each = condition.value.type == "HOST" ? ["go"] : []

        content {
          values = condition.value.values
        }
      }

      dynamic "http_request_method" {
        for_each = condition.value.type == "HTTP_METHOD" ? ["go"] : []

        content {
          values = condition.value.values
        }
      }

      dynamic "http_header" {
        for_each = condition.value.type == "HTTP_HEADER" ? ["go"] : []

        content {
          http_header_name = condition.value.name
          values           = condition.value.values
        }
      }

      dynamic "path_pattern" {
        for_each = condition.value.type == "PATH" ? ["go"] : []

        content {
          values = condition.value.values
        }
      }

      dynamic "query_string" {
        for_each = condition.value.type == "QUERY" ? condition.value.values : []

        content {
          key   = try(query_string.value.key, null)
          value = query_string.value.value
        }
      }

      dynamic "source_ip" {
        for_each = condition.value.type == "SOURCE_IP" ? ["go"] : []

        content {
          values = condition.value.values
        }
      }
    }
  }

  dynamic "action" {
    for_each = (each.value.action_type == "FORWARD"
      ? [each.value.action_parameters]
      : []
    )

    content {
      type = "forward"

      target_group_arn = action.value.target_group
    }
  }

  dynamic "action" {
    for_each = (each.value.action_type == "WEIGHTED_FORWARD"
      ? [each.value.action_parameters]
      : []
    )

    content {
      type = "forward"

      forward {
        dynamic "target_group" {
          for_each = action.value.targets

          content {
            arn    = target_group.value.target_group
            weight = try(target_group.value.weight, 1)
          }
        }
        dynamic "stickiness" {
          for_each = try(action.value.stickiness_duration, 0) > 0 ? ["go"] : []

          content {
            enabled  = true
            duration = action.value.stickiness_duration
          }
        }
      }
    }
  }

  dynamic "action" {
    for_each = (each.value.action_type == "FIXED_RESPONSE"
      ? [each.value.action_parameters]
      : []
    )

    content {
      type = "fixed-response"

      fixed_response {
        status_code  = try(action.value.status_code, 503)
        content_type = try(action.value.content_type, "text/plain")
        message_body = try(action.value.data, "")
      }
    }
  }

  dynamic "action" {
    for_each = (each.value.action_type == "REDIRECT_301"
      ? [each.value.action_parameters]
      : []
    )

    content {
      type = "redirect"

      redirect {
        status_code = "HTTP_301"
        protocol    = try(action.value.protocol, "#{protocol}")
        host        = try(action.value.host, "#{host}")
        port        = try(action.value.port, "#{port}")
        path        = try(action.value.path, "/#{path}")
        query       = try(action.value.query, "#{query}")
      }
    }
  }

  dynamic "action" {
    for_each = (each.value.action_type == "REDIRECT_302"
      ? [each.value.action_parameters]
      : []
    )

    content {
      type = "redirect"

      redirect {
        status_code = "HTTP_302"
        protocol    = try(action.value.protocol, "#{protocol}")
        host        = try(action.value.host, "#{host}")
        port        = try(action.value.port, "#{port}")
        path        = try(action.value.path, "/#{path}")
        query       = try(action.value.query, "#{query}")
      }
    }
  }

  dynamic "transform" {
    for_each = try(each.value.transforms, [])

    content {
      type = local.rule_transform_type[transform.value.type]

      dynamic "host_header_rewrite_config" {
        for_each = transform.value.type == "HOST_HEADER_REWRITE" ? [transform.value] : []

        content {
          rewrite {
            regex   = host_header_rewrite_config.value.rewrite.regex
            replace = host_header_rewrite_config.value.rewrite.replace
          }
        }
      }

      dynamic "url_rewrite_config" {
        for_each = transform.value.type == "URL_REWRITE" ? [transform.value] : []

        content {
          rewrite {
            regex   = url_rewrite_config.value.rewrite.regex
            replace = url_rewrite_config.value.rewrite.replace
          }
        }
      }
    }
  }

  tags = merge(
    {
      "Name" = "${local.metadata.name}/${each.key}"
    },
    local.module_tags,
    var.tags,
  )
}


###################################################
# Additional Certificates for Listener
###################################################

resource "aws_lb_listener_certificate" "this" {
  for_each = toset(local.tls_enabled ? var.tls.additional_certificates : [])

  region = var.region

  listener_arn    = aws_lb_listener.this.arn
  certificate_arn = each.key
}
