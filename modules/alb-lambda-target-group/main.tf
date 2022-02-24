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
# - `deregistration_delay`
# - `load_balancing_algorithm_type`
# - `preserve_client_ip`
# - `protocol`
# - `protocol_version`
# - `proxy_protocol_v2`
# - `port`
# - `slow_start`
# - `stickiness`
# - `vpc_id`
resource "aws_lb_target_group" "this" {
  name = var.name

  target_type = "lambda"

  ## Attributes
  lambda_multi_value_headers_enabled = var.multi_value_headers_enabled

  health_check {
    enabled = try(var.health_check.enabled, false)

    healthy_threshold   = try(var.health_check.healthy_threshold, 5)
    unhealthy_threshold = try(var.health_check.unhealthy_threshold, 2)
    interval            = try(var.health_check.interval, 35)
    timeout             = try(var.health_check.timeout, 30)

    matcher = try(var.health_check.success_codes, "200")
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
# Attachment for ALB Lambda Target Group
###################################################

# INFO: Not supported attributes
# - `port`
resource "aws_lb_target_group_attachment" "this" {
  count = length(var.targets) > 0 ? 1 : 0

  target_group_arn = aws_lb_target_group.this.arn

  # TODO: divide function name and alias
  target_id         = var.targets[0].lambda_function
  availability_zone = "all"

  depends_on = [
    aws_lambda_permission.this,
  ]
}


###################################################
# Permission for ALB Lambda Target Group
###################################################

resource "aws_lambda_permission" "this" {
  count = length(var.targets) > 0 ? 1 : 0

  function_name = var.targets[0].lambda_function

  statement_id_prefix = "AllowExecutionFromALB-"
  principal           = "elasticloadbalancing.amazonaws.com"
  action              = "lambda:InvokeFunction"
  source_arn          = aws_lb_target_group.this.arn
}
