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
  tls_enabled        = var.protocol == "TLS"
}


###################################################
# NLB Listener
###################################################

# INFO: Not supported attributes
# - `mutual_authentication` (ALB-only)
# - `routing_http_response_*` (ALB-only)
# - `routing_http_request_*` (ALB-only)
resource "aws_lb_listener" "this" {
  region = var.region

  load_balancer_arn = var.load_balancer

  port     = var.port
  protocol = var.protocol


  ## TLS
  certificate_arn = local.tls_enabled ? var.tls.certificate : null
  ssl_policy      = local.tls_enabled ? var.tls.security_policy : null
  alpn_policy     = local.tls_enabled ? var.tls.alpn_policy : null


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


  ## Attributes
  tcp_idle_timeout_seconds = (contains(["TCP", "TCP_UDP"], var.protocol)
    ? var.tcp_idle_timeout
    : null
  )

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
  for_each = toset(local.tls_enabled ? var.tls.additional_certificates : [])

  region = var.region

  listener_arn    = aws_lb_listener.this.arn
  certificate_arn = each.key
}
