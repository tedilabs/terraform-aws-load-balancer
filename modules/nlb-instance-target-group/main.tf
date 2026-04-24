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
# - `lambda_multi_value_headers_enabled`
# - `load_balancing_algorithm_type`
# - `load_balancing_anomaly_mitigation`
# - `protocol_version`
# - `slow_start`
# - `stickiness.cookie_duration`
# - `stickiness.cookie_name`
# - `target_control_port`
# - `target_failover`
resource "aws_lb_target_group" "this" {
  region = var.region

  name = var.name

  vpc_id = var.vpc_id

  target_type     = "instance"
  ip_address_type = lower(var.ip_address_type)
  port            = var.port
  protocol        = var.protocol


  ## Attributes
  connection_termination = (contains(["QUIC"], var.protocol)
    ? true
    : var.on_deregistration.connection_termination_enabled
  )
  deregistration_delay = (contains(["QUIC"], var.protocol)
    ? null
    : var.on_deregistration.draining_interval
  )

  dynamic "target_health_state" {
    for_each = !contains(["QUIC", "UDP", "TCP_UDP"], var.protocol) ? ["go"] : []

    content {
      enable_unhealthy_connection_termination = var.on_unhealthy.connection_termination_enabled
      unhealthy_draining_interval = (!var.on_unhealthy.connection_termination_enabled
        ? var.on_unhealthy.draining_interval
        : null
      )
    }
  }

  load_balancing_cross_zone_enabled = local.cross_zone_strategy[var.load_balancing.cross_zone_strategy]
  stickiness {
    enabled = (contains(["QUIC"], var.protocol)
      ? false
      : var.load_balancing.stickiness.enabled
    )
    type = "source_ip"

    # INFO: for drift
    cookie_duration = 0
  }

  preserve_client_ip = (contains(["UDP", "TCP_UDP", "QUIC", "TCP_QUIC"], var.protocol)
    ? true
    : (contains(["TCP", "TLS"], var.protocol)
      ? coalesce(var.preserve_client_ip, false)
      : coalesce(var.preserve_client_ip, true)
    )
  )
  proxy_protocol_v2 = (contains(["QUIC"], var.protocol)
    ? false
    : var.proxy_protocol_v2
  )


  ## Target Group Health Requirements
  target_group_health {
    dns_failover {
      minimum_healthy_targets_count = (var.dns_failover_condition.min_healthy_targets.count > 0
        ? var.dns_failover_condition.min_healthy_targets.count
        : "off"
      )
      minimum_healthy_targets_percentage = (var.dns_failover_condition.min_healthy_targets.percentage > 0
        ? var.dns_failover_condition.min_healthy_targets.percentage
        : "off"
      )
    }
    unhealthy_state_routing {
      minimum_healthy_targets_count = var.unhealthy_state_routing_condition.min_healthy_targets.count
      minimum_healthy_targets_percentage = (var.unhealthy_state_routing_condition.min_healthy_targets.percentage > 0
        ? var.unhealthy_state_routing_condition.min_healthy_targets.percentage
        : "off"
      )
    }
  }


  ## Health Check
  health_check {
    enabled = true

    protocol = var.health_check.protocol
    port = (var.health_check.port_override
      ? coalesce(var.health_check.port, var.port)
      : "traffic-port"
    )
    path = (var.health_check.protocol != "TCP"
      ? var.health_check.path
      : null
    )
    matcher = (var.health_check.protocol != "TCP"
      ? var.health_check.success_codes
      : null
    )

    healthy_threshold   = var.health_check.healthy_threshold
    unhealthy_threshold = var.health_check.unhealthy_threshold
    interval            = var.health_check.interval
    timeout = (var.health_check.protocol == "HTTP"
      ? coalesce(var.health_check.timeout, 6)
      : coalesce(var.health_check.timeout, 10)
    )
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

  region = var.region

  target_group_arn = aws_lb_target_group.this.arn

  target_id = each.key
  port      = try(each.value.port, var.port)
}
