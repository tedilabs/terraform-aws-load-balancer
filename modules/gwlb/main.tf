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
  load_balancer_type = "GATEWAY"

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
# Gateway Load Balancer
###################################################

# INFO: Not supported attributes
# - `access_logs`
# - `customer_owned_ipv4_pool`
# - `desync_mitigation_mode`
# - `dns_record_client_routing_policy`
# - `drop_invalid_header_fields`
# - `enable_http2`
# - `enable_tls_version_and_cipher_suite_headers`
# - `enable_waf_fail_open`
# - `enable_xff_client_port`
# - `enforce_security_group_inbound_rules_on_private_link_traffic`
# - `idle_timeout`
# - `internal`
# - `ip_address_type`
# - `preserve_host_header`
# - `security_groups`
# - `subnets`
# - `xff_header_processing_mode`
resource "aws_lb" "this" {
  name = var.name

  load_balancer_type = lower(local.load_balancer_type)

  dynamic "subnet_mapping" {
    for_each = local.enabled_network_mapping

    content {
      subnet_id = subnet_mapping.value.subnet
    }
  }


  ## Attributes
  enable_cross_zone_load_balancing = var.cross_zone_load_balancing_enabled
  enable_deletion_protection       = var.deletion_protection_enabled


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
