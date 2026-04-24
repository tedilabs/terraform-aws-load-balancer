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

data "aws_vpc" "this" {
  region = var.region

  id = var.vpc_id
}

locals {
  ipv4_regex = "^(\\d+).(\\d+).(\\d+).(\\d+)$"

  ipv4_vpc_cidrs = data.aws_vpc.this.cidr_block_associations[*].cidr_block
  ipv6_vpc_cidrs = [data.aws_vpc.this.ipv6_cidr_block]

  port = 6081
  targets = [
    for target in var.targets : {
      ip_address = target.ip_address
      port       = local.port
      az = anytrue([
        for cidr in(length(regexall(local.ipv4_regex, target.ip_address)) > 0 ? local.ipv4_vpc_cidrs : local.ipv6_vpc_cidrs) :
        cidr == cidrsubnet(format("%s/%s", target.ip_address, split("/", cidr)[1]), 0, 0)
      ]) ? null : "all"
    }
  ]
}


###################################################
# GWLB IP Target Group
###################################################

# INFO: Not supported attributes
# - `connection_termination`
# - `ip_address_type`
# - `lambda_multi_value_headers_enabled`
# - `load_balancing_algorithm_type`
# - `load_balancing_anomaly_mitigation`
# - `load_balancing_cross_zone_enabled`
# - `preserve_client_ip`
# - `protocol_version`
# - `proxy_protocol_v2`
# - `slow_start`
# - `stickiness`
# - `target_control_port`
# - `target_group_health`
# - `target_health_state`
resource "aws_lb_target_group" "this" {
  region = var.region

  name = var.name

  vpc_id = var.vpc_id

  target_type = "ip"
  port        = local.port
  protocol    = "GENEVE"


  ## Attributes
  deregistration_delay = var.deregistration_delay

  target_failover {
    on_deregistration = var.target_failover.rebalance_on_deregistration ? "rebalance" : "no_rebalance"
    on_unhealthy      = var.target_failover.rebalance_on_unhealthy ? "rebalance" : "no_rebalance"
  }

  dynamic "stickiness" {
    for_each = var.flow_stickiness.type == "5-tuple" ? ["go"] : []

    content {
      enabled = false
      type    = "source_ip_dest_ip_proto"
    }
  }
  dynamic "stickiness" {
    for_each = var.flow_stickiness.type == "3-tuple" ? ["go"] : []

    content {
      enabled = true
      type    = "source_ip_dest_ip_proto"
    }
  }
  dynamic "stickiness" {
    for_each = var.flow_stickiness.type == "2-tuple" ? ["go"] : []

    content {
      enabled = true
      type    = "source_ip_dest_ip"
    }
  }


  ## Health Check
  health_check {
    enabled = true

    protocol = var.health_check.protocol
    port = (var.health_check.port_override
      ? coalesce(var.health_check.port, 6081)
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
# Attachment for GWLB IP Target Group
###################################################

# INFO: Not supported attributes
# - `quic_server_id`
resource "aws_lb_target_group_attachment" "this" {
  for_each = {
    for target in local.targets :
    target.ip_address => target
  }

  region = var.region

  target_group_arn = aws_lb_target_group.this.arn

  target_id         = each.key
  port              = each.value.port
  availability_zone = each.value.az
}
