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


data "aws_lb" "this" {
  for_each = toset(try(var.targets.*.alb, []))

  name = each.value
}

# INFO: Not supported attributes
# - `connection_termination`
# - `lambda_multi_value_headers_enabled`
# - `load_balancing_algorithm_type`
# - `protocol_version`
# - `proxy_protocol_v2`
# - `slow_start`
resource "aws_lb_target_group" "this" {
  name = var.name

  vpc_id = var.vpc_id

  target_type = "alb"
  port        = var.port
  protocol    = "TCP"

  ## Attributes
  ## INFO: Not supported to edit
  # deregistration_delay = 300
  # preserve_client_ip = true
  # stickiness {
  # }

  ## INFO: Not supported attributes
  # - `timeout`
  health_check {
    enabled = true

    port     = try(var.health_check.port, var.port)
    protocol = try(var.health_check.protocol, "HTTP")

    healthy_threshold   = try(var.health_check.healthy_threshold, 3)
    unhealthy_threshold = try(var.health_check.unhealthy_threshold, 3)
    interval            = try(var.health_check.interval, 30)

    matcher = "200-399"
    path    = try(var.health_check.path, "/")
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
  for_each = {
    for target in var.targets :
    target.alb => target
  }

  target_group_arn = aws_lb_target_group.this.arn

  target_id = data.aws_lb.this[each.value.alb].arn
  port      = var.port
}
