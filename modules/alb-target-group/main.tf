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
# - `deregistration_delay`
# - `lambda_multi_value_headers_enabled`
# - `preserve_client_ip`
resource "aws_lb_target_group" "this" {
  name = var.name

  vpc_id = var.vpc_id

  target_type = "alb"
  protocol    = "TCP"
  port        = var.port

  # slow_start
  # stickiness
  # proxy_protocol_v2
  # protococl_version
  # load_balancing_algorithm_type
  # health_check
  # connection_termination

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}


###################################################
# Attachment for ALB Target Group
###################################################

# INFO: Not supported attributes
# - `availability_zone`
resource "aws_lb_target_group_attachment" "this" {
  count = var.target_alb != null ? 1 : 0

  target_group_arn = aws_lb_target_group.this.arn

  target_id = var.target_alb
  port      = var.port
}
