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


# INFO: Not supported attributes
# - `connection_termination`
# - `lambda_multi_value_headers_enabled`
# - `preserve_client_ip`
# - `proxy_protocol_v2`
resource "aws_lb_target_group" "this" {
  name = var.name

  vpc_id = var.vpc_id

  target_type      = "instance"
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

    port     = try(var.health_check.port, var.port)
    protocol = try(var.health_check.protocol, "HTTP")

    healthy_threshold   = try(var.health_check.healthy_threshold, 5)
    unhealthy_threshold = try(var.health_check.unhealthy_threshold, 2)
    interval            = try(var.health_check.interval, 30)
    timeout             = try(var.health_check.timeout, 5)

    matcher = (var.protocol_version != "GRPC"
      ? try(var.health_check.success_codes, "200")
    : try(var.health_check.success_codes, "12"))
    path = (var.protocol_version != "GRPC"
      ? try(var.health_check.path, "/")
    : try(var.health_check.path, "/AWS.ALB/healthcheck"))
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
resource "aws_lb_target_group_attachment" "this" {
  for_each = {
    for target in var.targets :
    target.instance => target
  }

  target_group_arn = aws_lb_target_group.this.arn

  target_id = each.key
  port      = try(each.value.port, var.port)
}
