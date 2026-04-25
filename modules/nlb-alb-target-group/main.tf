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


###################################################
# NLB ALB Target Group
###################################################

# INFO: Not supported attributes
# - `connection_termination`
# - `deregistration_delay` (fixed to `300` by AWS)
# - `ip_address_type`
# - `lambda_multi_value_headers_enabled`
# - `load_balancing_algorithm_type`
# - `load_balancing_anomaly_mitigation`
# - `load_balancing_cross_zone_enabled` (fixed to `INHERIT` by AWS)
# - `preserve_client_ip` (fixed to `true` by AWS)
# - `protocol_version`
# - `proxy_protocol_v2`
# - `slow_start`
# - `stickiness` (fixed to disabled `source_ip` by AWS)
# - `target_control_port`
# - `target_failover`
# - `target_group_health`
# - `target_health_state`
resource "aws_lb_target_group" "this" {
  region = var.region

  name = var.name

  vpc_id = var.vpc_id

  target_type = "alb"
  port        = var.port
  protocol    = "TCP"


  ## Health Check
  health_check {
    enabled = true

    protocol = var.health_check.protocol
    port = (var.health_check.port_override
      ? coalesce(var.health_check.port, var.port)
      : "traffic-port"
    )
    path    = var.health_check.path
    matcher = var.health_check.success_codes

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
# Attachment for NLB ALB Target Group
###################################################

# INFO: Not supported attributes
# - `availability_zone`
resource "aws_lb_target_group_attachment" "this" {
  count = length(var.targets) > 0 ? 1 : 0

  region = var.region

  target_group_arn = aws_lb_target_group.this.arn

  target_id = tolist(var.targets)[0].alb
  port      = var.port
}
