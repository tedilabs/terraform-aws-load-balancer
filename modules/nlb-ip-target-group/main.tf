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
  id = var.vpc_id
}

locals {
  ipv4_regex = "^(\\d+).(\\d+).(\\d+).(\\d+)$"

  ipv4_vpc_cidrs = data.aws_vpc.this.cidr_block_associations[*].cidr_block
  ipv6_vpc_cidrs = [data.aws_vpc.this.ipv6_cidr_block]

  targets = [
    for target in var.targets : {
      ip_address = target.ip_address
      port       = try(target.port, var.port)
      az = anytrue([
        for cidr in(length(regexall(local.ipv4_regex, target.ip_address)) > 0 ? local.ipv4_vpc_cidrs : local.ipv6_vpc_cidrs) :
        cidr == cidrsubnet(format("%s/%s", target.ip_address, split("/", cidr)[1]), 0, 0)
      ]) ? null : "all"
    }
  ]
}

# INFO: Not supported attributes
# - `lambda_multi_value_headers_enabled`
# - `load_balancing_algorithm_type`
# - `load_balancing_anomaly_mitigation`
# - `protocol_version`
# - `slow_start`
resource "aws_lb_target_group" "this" {
  name = var.name

  vpc_id = var.vpc_id

  target_type     = "ip"
  ip_address_type = lower(var.ip_address_type)
  port            = var.port
  protocol        = var.protocol

  ## Attributes
  connection_termination = var.terminate_connection_on_deregistration
  deregistration_delay   = var.deregistration_delay
  preserve_client_ip     = var.preserve_client_ip
  proxy_protocol_v2      = var.proxy_protocol_v2

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
# Attachment for NLB IP Target Group
###################################################

resource "aws_lb_target_group_attachment" "this" {
  for_each = {
    for target in local.targets :
    target.ip_address => target
  }

  target_group_arn = aws_lb_target_group.this.arn

  target_id         = each.key
  port              = each.value.port
  availability_zone = each.value.az
}
