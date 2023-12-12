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

resource "terraform_data" "replace_trigger" {
  input = length(local.security_groups) > 0
}

locals {
  load_balancer_type = "NETWORK"

  available_availability_zone_ids = data.aws_availability_zones.available.zone_ids
  network_mapping = {
    for zone_id in local.available_availability_zone_ids :
    zone_id => (contains(keys(var.network_mapping), zone_id)
      ? {
        subnet = data.aws_subnet.this[zone_id].id

        ipv4_cidr            = data.aws_subnet.this[zone_id].cidr_block != "" ? data.aws_subnet.this[zone_id].cidr_block : null
        ipv6_cidr            = data.aws_subnet.this[zone_id].ipv6_cidr_block != "" ? data.aws_subnet.this[zone_id].ipv6_cidr_block : null
        private_ipv4_address = var.network_mapping[zone_id].private_ipv4_address
        ipv6_address         = var.network_mapping[zone_id].ipv6_address
        elastic_ip           = var.network_mapping[zone_id].elastic_ip
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

  route53_resolver_availability_zone_affinity = {
    "ANY"     = "any_availability_zone"
    "PARTIAL" = "partial_availability_zone_affinity"
    "ALL"     = "availability_zone_affinity"
  }
}


###################################################
# Network Load Balancer
###################################################

# INFO: Not supported attributes
# - `customer_owned_ipv4_pool`
# - `desync_mitigation_mode`
# - `drop_invalid_header_fields`
# - `enable_http2`
# - `enable_tls_version_and_cipher_suite_headers`
# - `enable_waf_fail_open`
# - `enable_xff_client_port`
# - `idle_timeout`
# - `preserve_host_header`
# - `subnets`
# - `xff_header_processing_mode`
resource "aws_lb" "this" {
  name = var.name

  load_balancer_type = lower(local.load_balancer_type)
  internal           = !var.is_public
  ip_address_type    = lower(var.ip_address_type)

  dynamic "subnet_mapping" {
    for_each = local.enabled_network_mapping

    content {
      subnet_id = subnet_mapping.value.subnet

      private_ipv4_address = subnet_mapping.value.private_ipv4_address
      ipv6_address         = subnet_mapping.value.ipv6_address
      allocation_id        = subnet_mapping.value.elastic_ip
    }
  }


  ## Access Control
  enforce_security_group_inbound_rules_on_private_link_traffic = (length(local.security_groups) > 0
    ? (var.security_group_evaluation_on_privatelink_enabled ? "on" : "off")
    : null
  )
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
  dns_record_client_routing_policy = local.route53_resolver_availability_zone_affinity[var.route53_resolver_availability_zone_affinity]
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

  lifecycle {
    replace_triggered_by = [
      terraform_data.replace_trigger,
    ]
  }
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
  tls = {
    certificate             = each.value.tls.certificate
    additional_certificates = each.value.tls.additional_certificates
    security_policy         = each.value.tls.security_policy
    alpn_policy             = each.value.tls.alpn_policy
  }

  resource_group_enabled = false
  module_tags_enabled    = false

  tags = merge(
    local.module_tags,
    var.tags,
  )
}
