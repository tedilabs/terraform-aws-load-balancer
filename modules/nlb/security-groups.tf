locals {
  security_groups = concat(
    (var.default_security_group.enabled
      ? module.security_group[*].id
      : []
    ),
    var.security_groups,
  )
}


###################################################
# Security Group for Network Load Balancer
###################################################

module "security_group" {
  source  = "tedilabs/network/aws//modules/security-group"
  version = "~> 0.32.0"

  count = var.default_security_group.enabled ? 1 : 0

  name        = coalesce(var.default_security_group.name, local.metadata.name)
  description = var.default_security_group.description
  vpc_id      = values(data.aws_subnet.this)[0].vpc_id

  ingress_rules = concat(
    var.default_security_group.ingress_rules,
    [
      for listener in var.listeners : {
        id          = "listener-${listener.port}"
        description = "Default rule for the load balancer listener."
        protocol    = "tcp"
        from_port   = listener.port
        to_port     = listener.port

        ipv4_cidrs      = var.default_security_group.listener_ingress_ipv4_cidrs
        ipv6_cidrs      = var.default_security_group.listener_ingress_ipv6_cidrs
        prefix_lists    = var.default_security_group.listener_ingress_prefix_lists
        security_groups = var.default_security_group.listener_ingress_security_groups
      }
      if contains(["TCP", "TLS", "TCP_UDP"], listener.protocol) && anytrue([
        length(var.default_security_group.listener_ingress_ipv4_cidrs) > 0,
        length(var.default_security_group.listener_ingress_ipv6_cidrs) > 0,
        length(var.default_security_group.listener_ingress_prefix_lists) > 0,
        length(var.default_security_group.listener_ingress_security_groups) > 0,
      ])
    ],
    [
      for listener in var.listeners : {
        id          = "listener-${listener.port}-udp"
        description = "Default rule for the load balancer listener."
        protocol    = "udp"
        from_port   = listener.port
        to_port     = listener.port

        ipv4_cidrs      = var.default_security_group.listener_ingress_ipv4_cidrs
        ipv6_cidrs      = var.default_security_group.listener_ingress_ipv6_cidrs
        prefix_lists    = var.default_security_group.listener_ingress_prefix_lists
        security_groups = var.default_security_group.listener_ingress_security_groups
      }
      if contains(["UDP"], listener.protocol) && anytrue([
        length(var.default_security_group.listener_ingress_ipv4_cidrs) > 0,
        length(var.default_security_group.listener_ingress_ipv6_cidrs) > 0,
        length(var.default_security_group.listener_ingress_prefix_lists) > 0,
        length(var.default_security_group.listener_ingress_security_groups) > 0,
      ])
    ],
  )
  egress_rules = concat(
    var.default_security_group.egress_rules,
    # TODO: Limit egress rules
    # TODO: Target Ports
    # TODO: Target Health Check Ports
  )

  revoke_rules_on_delete = true
  resource_group_enabled = false
  module_tags_enabled    = false

  tags = merge(
    local.module_tags,
    var.tags,
  )
}
