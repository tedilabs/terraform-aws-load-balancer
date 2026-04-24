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
# ALB Instance Target Group
###################################################

# INFO: Not supported attributes
# - `connection_termination`
# - `lambda_multi_value_headers_enabled`
# - `preserve_client_ip`
# - `proxy_protocol_v2`
# - `target_failover`
# - `target_health_state`
resource "aws_lb_target_group" "this" {
  region = var.region

  name = var.name

  vpc_id = var.vpc_id

  target_type      = "instance"
  ip_address_type  = lower(var.ip_address_type)
  port             = var.port
  protocol         = var.protocol
  protocol_version = var.protocol_version


  ## Attributes
  deregistration_delay = var.deregistration_delay

  load_balancing_algorithm_type = lower(var.load_balancing.algorithm)
  load_balancing_anomaly_mitigation = (var.load_balancing.algorithm == "WEIGHTED_RANDOM"
    ? var.load_balancing.anomaly_mitigation_enabled ? "on" : "off"
    : null
  )
  load_balancing_cross_zone_enabled = local.cross_zone_strategy[var.load_balancing.cross_zone_strategy]
  slow_start = (!contains(["LEAST_OUTSTANDING_REQUESTS", "WEIGHTED_RANDOM"], var.load_balancing.algorithm)
    ? var.load_balancing.slow_start_duration
    : null
  )
  stickiness {
    enabled         = var.load_balancing.stickiness.enabled
    type            = lower(var.load_balancing.stickiness.type)
    cookie_duration = var.load_balancing.stickiness.duration
    cookie_name = (var.load_balancing.stickiness.type == "APP_COOKIE"
      ? var.load_balancing.stickiness.cookie
      : null
    )
  }


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


  ## Target Optimizer
  target_control_port = var.target_optimizer.target_control_port


  ## Health Check
  health_check {
    enabled = true

    protocol = var.health_check.protocol
    port = (var.health_check.port_override
      ? coalesce(var.health_check.port, var.port)
      : "traffic-port"
    )
    path = (var.protocol_version != "GRPC"
      ? coalesce(var.health_check.path, "/")
      : coalesce(var.health_check.path, "/AWS.ALB/healthcheck")
    )
    matcher = (var.protocol_version != "GRPC"
      ? coalesce(var.health_check.success_codes, "200")
      : coalesce(var.health_check.success_codes, "12")
    )

    healthy_threshold   = var.health_check.healthy_threshold
    unhealthy_threshold = var.health_check.unhealthy_threshold
    interval            = var.health_check.interval
    timeout             = var.health_check.timeout
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
# Attachment for ALB Instance Target Group
###################################################

# INFO: Not supported attributes
# - `availability_zone`
# - `quic_server_id`
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
