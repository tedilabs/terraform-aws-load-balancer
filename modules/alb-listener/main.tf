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


data "aws_lb" "this" {
  arn = var.load_balancer
}

data "aws_lb_target_group" "this" {
  for_each = setunion(
    try([var.default_action_parameters.target_group], []),
    try(var.default_action_parameters.targets.*.target_group, []),
  )

  arn = each.value
}

locals {
  load_balancer_name = data.aws_lb.this.name
  tls_enabled        = var.protocol == "HTTPS"
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = var.load_balancer

  port     = var.port
  protocol = var.protocol

  ## TLS
  certificate_arn = local.tls_enabled ? var.tls_certificate : null
  ssl_policy      = local.tls_enabled ? var.tls_security_policy : null

  dynamic "default_action" {
    for_each = (var.default_action_type == "FORWARD"
      ? [var.default_action_parameters]
    : [])

    content {
      type = "forward"

      target_group_arn = default_action.value.target_group
    }
  }

  dynamic "default_action" {
    for_each = (var.default_action_type == "WEIGHTED_FORWARD"
      ? [var.default_action_parameters]
    : [])

    content {
      type = "forward"

      forward {
        dynamic "target_group" {
          for_each = default_action.value.targets

          content {
            arn    = target_group.value.target_group
            weight = try(target_group.value.weight, 1)
          }
        }
        dynamic "stickiness" {
          for_each = try(default_action.value.stickiness_duration, 0) > 0 ? ["go"] : []

          content {
            enabled  = true
            duration = default_action.value.stickiness_duration
          }
        }
      }
    }
  }

  dynamic "default_action" {
    for_each = (var.default_action_type == "FIXED_RESPONSE"
      ? [var.default_action_parameters]
    : [])

    content {
      type = "fixed-response"

      fixed_response {
        status_code  = try(default_action.value.status_code, 503)
        content_type = try(default_action.value.content_type, "text/plain")
        message_body = try(default_action.value.data, "")
      }
    }
  }

  dynamic "default_action" {
    for_each = (var.default_action_type == "REDIRECT_301"
      ? [var.default_action_parameters]
    : [])

    content {
      type = "redirect"

      redirect {
        status_code = "HTTP_301"
        protocol    = try(default_action.value.protocol, "#{protocol}")
        host        = try(default_action.value.host, "#{host}")
        port        = try(default_action.value.port, "#{port}")
        path        = try(default_action.value.path, "/#{path}")
        query       = try(default_action.value.query, "#{query}")
      }
    }
  }

  dynamic "default_action" {
    for_each = (var.default_action_type == "REDIRECT_302"
      ? [var.default_action_parameters]
    : [])

    content {
      type = "redirect"

      redirect {
        status_code = "HTTP_302"
        protocol    = try(default_action.value.protocol, "#{protocol}")
        host        = try(default_action.value.host, "#{host}")
        port        = try(default_action.value.port, "#{port}")
        path        = try(default_action.value.path, "/#{path}")
        query       = try(default_action.value.query, "#{query}")
      }
    }
  }

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}


###################################################
# Additional Certificates for Listeners
###################################################

resource "aws_lb_listener_certificate" "this" {
  for_each = toset(local.tls_enabled ? var.tls_additional_certificates : [])

  listener_arn    = aws_lb_listener.this.arn
  certificate_arn = each.key
}
