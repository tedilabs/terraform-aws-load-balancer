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


data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnet" "this" {
  for_each = var.network_mapping

  id = each.value.subnet_id
}

locals {
  load_balancer_type = "GATEWAY"

  available_availability_zone_ids = data.aws_availability_zones.available.zone_ids
  network_mapping = {
    for zone_id in local.available_availability_zone_ids :
    zone_id => try(merge({
      cidr_block = data.aws_subnet.this[zone_id].cidr_block != "" ? data.aws_subnet.this[zone_id].cidr_block : null
    }, var.network_mapping[zone_id]), null)
  }
  enabled_network_mapping = {
    for zone_id, config in local.network_mapping :
    zone_id => config
    if try(config.subnet_id, null) != null
  }
  availability_zone_ids = keys(local.enabled_network_mapping)
}

# INFO: Not supported attributes
# - `access_logs`
# - `customer_owned_ipv4_pool`
# - `desync_mitigation_mode`
# - `drop_invalid_header_fields`
# - `enable_http2`
# - `enable_waf_fail_open`
# - `idle_timeout`
# - `internal`
# - `ip_address_type`
# - `security_groups`
resource "aws_lb" "this" {
  name = var.name

  load_balancer_type = lower(local.load_balancer_type)

  dynamic "subnet_mapping" {
    for_each = local.enabled_network_mapping

    content {
      subnet_id = subnet_mapping.value.subnet_id
    }
  }

  ## Attributes
  enable_cross_zone_load_balancing = var.cross_zone_load_balancing_enabled
  enable_deletion_protection       = var.deletion_protection_enabled

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}


###################################################
# Listeners for Gateway Load Balancer
###################################################

# INFO: Not supported attributes
# - `alpn_policy`
# - `certificate_arn`
# - `port`
# - `protocol`
# - `ssl_policy`
# - `tags`
resource "aws_lb_listener" "this" {
  count = length(var.listeners) > 0 ? 1 : 0

  load_balancer_arn = aws_lb.this.arn

  default_action {
    type             = "forward"
    target_group_arn = var.listeners[0].target_group
  }
}
