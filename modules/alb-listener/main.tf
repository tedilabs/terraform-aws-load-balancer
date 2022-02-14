locals {
  metadata = {
    package = "terraform-aws-load-balancer"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = "${local.load_balancer_name}/${var.protocol}:${var.port}"
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
  arn = var.load_balancer
}

data "aws_lb_target_group" "this" {
  arn = var.target_group
}

locals {
  load_balancer_name = data.aws_lb.this.name
  tls_enabled        = var.protocol == "HTTPS"
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = var.load_balancer

  port     = var.port
  protocol = var.protocol

  ## TLS
  certificate_arn = local.tls_enabled ? var.tls_certificate : null
  ssl_policy      = local.tls_enabled ? var.tls_security_policy : null

  default_action {
    type             = "forward"
    target_group_arn = var.target_group
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
# Additional Certificates for Listeners
###################################################

resource "aws_lb_listener_certificate" "this" {
  for_each = toset(local.tls_enabled ? var.tls_additional_certificates : [])

  listener_arn    = aws_lb_listener.this.arn
  certificate_arn = each.key
}
