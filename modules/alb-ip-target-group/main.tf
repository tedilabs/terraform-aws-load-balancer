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
# - `connection_termination`
# - `lambda_multi_value_headers_enabled`
# - `preserve_client_ip`
# - `proxy_protocol_v2`
resource "aws_lb_target_group" "this" {
  name = var.name

  vpc_id = var.vpc_id

  target_type      = "ip"
  ip_address_type  = lower(var.ip_address_type)
  port             = var.port
  protocol         = var.protocol
  protocol_version = var.protocol_version

  ## Attributes
  deregistration_delay          = var.deregistration_delay
  load_balancing_algorithm_type = lower(var.load_balancing_algorithm)
  slow_start                    = var.slow_start_duration

  stickiness {
    enabled         = var.stickiness_enabled
    type            = lower(var.stickiness_type)
    cookie_duration = var.stickiness_duration
    cookie_name     = var.stickiness_type == "APP_COOKIE" ? var.stickiness_cookie : null
  }

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
# Attachment for ALB IP Target Group
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
