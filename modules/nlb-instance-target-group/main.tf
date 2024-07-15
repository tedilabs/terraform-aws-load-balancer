locals {
  metadata = {
    package = "terraform-aws-load-balancer"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = var.name
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
  cross_zone_strategy = {
    "ENABLED"  = "true"
    "DISABLED" = "false"
    "INHERIT"  = "use_load_balancer_configuration"
  }
}


###################################################
# NLB Instance Target Group
###################################################

# INFO: Not supported attributes
# - `ip_address_type`
# - `lambda_multi_value_headers_enabled`
# - `load_balancing_algorithm_type`
# - `load_balancing_anomaly_mitigation`
# - `protocol_version`
# - `slow_start`
resource "aws_lb_target_group" "this" {
  name = var.name

  vpc_id = var.vpc_id

  target_type = "instance"
  port        = var.port
  protocol    = var.protocol

  ## Attributes
  connection_termination            = var.terminate_connection_on_deregistration
  deregistration_delay              = var.deregistration_delay
  load_balancing_cross_zone_enabled = local.cross_zone_strategy[var.load_balancing.cross_zone_strategy]
  preserve_client_ip                = var.preserve_client_ip
  proxy_protocol_v2                 = var.proxy_protocol_v2

  ## INFO: Not supported attributes
  # - `cookie_duration`
  # - `cookie_name`
  stickiness {
    enabled = var.stickiness_enabled
    type    = "source_ip"
  }

  ## INFO: Not supported attributes
  # - `timeout`
  dynamic "health_check" {
    for_each = [merge(
      var.health_check,
      var.health_check.protocol != "TCP"
      ? {
        success_codes = "200-399"
      }
      : {
        success_codes = null
        path          = null
      },
    )]

    content {
      enabled = true

      protocol = health_check.value.protocol
      port = (health_check.value.port_override
        ? coalesce(health_check.value.port, var.port)
        : "traffic-port"
      )
      path    = health_check.value.path
      matcher = health_check.value.success_codes

      healthy_threshold   = health_check.value.healthy_threshold
      unhealthy_threshold = health_check.value.unhealthy_threshold
      interval            = health_check.value.interval
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
# Attachment for NLB Instance Target Group
###################################################

# INFO: Not supported attributes
# - `availability_zone`
resource "aws_lb_target_group_attachment" "this" {
  for_each = {
    for target in var.targets :
    target.instance => target
  }

  target_group_arn = aws_lb_target_group.this.arn

  target_id = each.key
  port      = try(each.value.port, var.port)
}
