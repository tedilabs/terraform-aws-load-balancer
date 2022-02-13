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
  load_balancer_type = "NETWORK"

  available_availability_zone_ids = data.aws_availability_zones.available.zone_ids
  network_mapping = {
    for zone_id in local.available_availability_zone_ids :
    zone_id => try(merge({
      cidr_block           = data.aws_subnet.this[zone_id].cidr_block != "" ? data.aws_subnet.this[zone_id].cidr_block : null
      ipv6_cidr_block      = data.aws_subnet.this[zone_id].ipv6_cidr_block != "" ? data.aws_subnet.this[zone_id].ipv6_cidr_block : null
      private_ipv4_address = null
      ipv6_address         = null
      allocation_id        = null
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
# - `customer_owned_ipv4_pool`
# - `desync_mitigation_mode`
# - `drop_invalid_header_fields`
# - `enable_http2`
# - `enable_waf_fail_open`
# - `idle_timeout`
# - `security_groups`
resource "aws_lb" "this" {
  name = var.name

  load_balancer_type = lower(local.load_balancer_type)
  internal           = !var.is_public
  ip_address_type    = lower(var.ip_address_type)

  dynamic "subnet_mapping" {
    for_each = local.enabled_network_mapping

    content {
      subnet_id = subnet_mapping.value.subnet_id

      private_ipv4_address = try(subnet_mapping.value.private_ipv4_address, null)
      ipv6_address         = try(subnet_mapping.value.ipv6_address, null)
      allocation_id        = try(subnet_mapping.value.allocation_id, null)
    }
  }

  dynamic "access_logs" {
    for_each = var.access_log_enabled ? ["go"] : []

    content {
      enabled = var.access_log_enabled
      bucket  = var.access_log_s3_bucket
      prefix  = var.access_log_s3_key_prefix
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
# Listeners for Network Load Balancer
###################################################

module "listener" {
  source = "../nlb-listener"

  for_each = {
    for listener in var.listeners :
    listener.port => listener
  }

  load_balancer = aws_lb.this.arn

  port         = each.key
  protocol     = each.value.protocol
  target_group = each.value.target_group

  ## TLS
  tls_certificate             = try(each.value.tls_certificate, null)
  tls_additional_certificates = try(each.value.tls_additional_certificates, [])
  tls_security_policy         = try(each.value.tls_security_policy, "ELBSecurityPolicy-TLS13-1-2-2021-06")
  tls_alpn_policy             = try(each.value.tls_alpn_policy, "None")

  resource_group_enabled = false
  module_tags_enabled    = false

  tags = merge(
    local.module_tags,
    var.tags,
  )
}
