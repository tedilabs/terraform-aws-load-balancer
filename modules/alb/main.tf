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

  id = each.value.subnet
}

locals {
  load_balancer_type = "APPLICATION"

  available_availability_zone_ids = data.aws_availability_zones.available.zone_ids
  network_mapping = {
    for zone_id in local.available_availability_zone_ids :
    zone_id => (contains(keys(var.network_mapping), zone_id)
      ? {
        subnet = data.aws_subnet.this[zone_id].id

        ipv4_cidr = data.aws_subnet.this[zone_id].cidr_block != "" ? data.aws_subnet.this[zone_id].cidr_block : null
        ipv6_cidr = data.aws_subnet.this[zone_id].ipv6_cidr_block != "" ? data.aws_subnet.this[zone_id].ipv6_cidr_block : null
      }
      : null
    )
  }
  enabled_network_mapping = {
    for zone_id, config in local.network_mapping :
    zone_id => config
    if config != null
  }
  availability_zone_ids = keys(local.enabled_network_mapping)
}


###################################################
# Application Load Balancer
###################################################

# INFO: Not supported attributes
# - `customer_owned_ipv4_pool`
# - `dns_record_client_routing_policy`
# - `enforce_security_group_inbound_rules_on_private_link_traffic`
# - `subnets`
# TODO: `customer_owned_ipv4_pool` (ALB Only)
resource "aws_lb" "this" {
  name = var.name

  load_balancer_type = lower(local.load_balancer_type)
  internal           = !var.is_public
  ip_address_type    = lower(var.ip_address_type)

  dynamic "subnet_mapping" {
    for_each = local.enabled_network_mapping

    content {
      subnet_id = subnet_mapping.value.subnet
    }
  }


  ## Access Control
  security_groups = local.security_groups


  ## Logging
  dynamic "access_logs" {
    for_each = var.access_log.enabled ? [var.access_log] : []
    iterator = log

    content {
      enabled = log.value.enabled
      bucket  = log.value.s3_bucket.name
      prefix  = log.value.s3_bucket.key_prefix
    }
  }


  ## Attributes
  desync_mitigation_mode           = lower(var.desync_mitigation_mode)
  enable_cross_zone_load_balancing = var.cross_zone_load_balancing_enabled
  enable_deletion_protection       = var.deletion_protection_enabled
  enable_http2                     = var.http2_enabled
  enable_waf_fail_open             = var.waf_fail_open_enabled
  idle_timeout                     = var.idle_timeout

  # Headers
  drop_invalid_header_fields                  = var.drop_invalid_header_fields
  enable_tls_version_and_cipher_suite_headers = var.tls_negotiation_headers_enabled
  preserve_host_header                        = var.preserve_host_header
  enable_xff_client_port                      = var.xff_header.client_port_preservation_enabled
  xff_header_processing_mode                  = lower(var.xff_header.mode)


  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
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
# Listeners for Application Load Balancer
###################################################

module "listener" {
  source = "../alb-listener"

  for_each = {
    for listener in var.listeners :
    listener.port => listener
  }

  load_balancer = aws_lb.this.arn

  port     = each.key
  protocol = each.value.protocol

  default_action_type       = each.value.default_action_type
  default_action_parameters = each.value.default_action_parameters

  rules = try(each.value.rules, {})

  ## TLS
  tls = {
    certificate             = try(each.value.tls.certificate, null)
    additional_certificates = try(each.value.tls.additional_certificates, [])
    security_policy         = try(each.value.tls.security_policy, "ELBSecurityPolicy-2016-08")
  }

  resource_group = {
    enabled = false
  }
  module_tags_enabled = false

  tags = merge(
    local.module_tags,
    var.tags,
  )
}
