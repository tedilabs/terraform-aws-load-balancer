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
  port = 6081
  targets = [
    for target in var.targets : {
      instance = target.instance
      port     = local.port
    }
  ]
}

# INFO: Not supported attributes
# - `connection_termination`
# - `ip_address_type`
# - `lambda_multi_value_headers_enabled`
# - `load_balancing_algorithm_type`
# - `preserve_client_ip`
# - `protocol_version`
# - `proxy_protocol_v2`
# - `slow_start`
# - `stickiness`
# - `tags`
resource "aws_lb_target_group" "this" {
  name = var.name

  vpc_id = var.vpc_id

  target_type = "instance"
  port        = local.port
  protocol    = "GENEVE"

  ## Attributes
  deregistration_delay = var.deregistration_delay

  ## INFO: Too many bugs in terraform provider
  # - `healthy_threshold` doesn't need to be same with `unhealthy_threashold`
  # - `interval` doesn't apply to the acutal resource
  # - `timeout` is not supported
  dynamic "health_check" {
    for_each = [merge(
      var.health_check,
      var.health_check.protocol != "TCP"
      ? {
        success_codes = "200-399"
      }
      : {
        interval      = null
        timeout       = null
        success_codes = null
        path          = null
      },
    )]

    content {
      enabled = true

      protocol = health_check.value.protocol
      port = (health_check.value.port_override
        ? health_check.value.port
        : "traffic-port"
      )
      path    = health_check.value.path
      matcher = health_check.value.success_codes

      healthy_threshold   = health_check.value.healthy_threshold
      unhealthy_threshold = health_check.value.unhealthy_threshold
      interval            = health_check.value.interval
      timeout             = health_check.value.timeout
    }
  }

  # INFO: Not supported on creation time. Only available on modification time.
  tags = merge(
    # {
    #   "Name" = local.metadata.name
    # },
    # local.module_tags,
    var.tags,
  )
}


###################################################
# Attachment for GWLB Instance Target Group
###################################################

# INFO: Not supported attributes
# - `availability_zone`
resource "aws_lb_target_group_attachment" "this" {
  for_each = {
    for target in local.targets :
    target.instance => target
  }

  target_group_arn = aws_lb_target_group.this.arn

  target_id = each.key
  port      = each.value.port
}
