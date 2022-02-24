###################################################
# Security Group for Application Load Balancer
###################################################

module "security_group" {
  source  = "tedilabs/network/aws//modules/security-group"
  version = "~> 0.25.0"

  vpc_id = var.vpc_id

  name        = try(var.default_security_group.name, local.metadata.name)
  description = try(var.default_security_group.description, "Managed by Terraform.")

  ingress_rules = concat(
    [
      for listener in var.listeners : {
        id          = "${listener.port}/cidrs"
        description = "Allow inbound traffic from the CIDRs on the load balancer listener port."
        protocol    = "tcp"
        from_port   = listener.port
        to_port     = listener.port

        cidr_blocks      = try(var.default_security_group.ingress_cidrs, [])
        ipv6_cidr_blocks = try(var.default_security_group.ingress_ipv6_cidrs, [])
      }
      if anytrue([
        length(try(var.default_security_group.ingress_cidrs, [])) > 0,
        length(try(var.default_security_group.ingress_ipv6_cidrs, [])) > 0,
      ])
    ],
    [
      for listener in var.listeners : {
        id          = "${listener.port}/prefix-lists"
        description = "Allow inbound traffic from the Prefix Lists on the load balancer listener port."
        protocol    = "tcp"
        from_port   = listener.port
        to_port     = listener.port

        prefix_list_ids = try(var.default_security_group.ingress_prefix_lists, [])
      }
      if length(try(var.default_security_group.ingress_prefix_lists, [])) > 0
    ],
    flatten([
      for listener in var.listeners : [
        for security_group in try(var.default_security_group.ingress_security_groups, []) : {
          id          = "${listener.port}/security-groups"
          description = "Allow inbound traffic from the source Security Groups on the load balancer listener port."
          protocol    = "tcp"
          from_port   = listener.port
          to_port     = listener.port

          source_security_group_id = security_group
        }
      ]
    ]),
  )
  # TODO: Limit egress rules
  egress_rules = concat(
    [
      {
        id          = "instance-listener/cidrs"
        description = "Allow outbound traffic to instances on the instance listener port."
        protocol    = "tcp"
        from_port   = 1
        to_port     = 65535

        cidr_blocks = ["0.0.0.0/0"]
      },
    ],
    # [
    #   {
    #     id          = "instance-health-check/cidrs"
    #     description = "Allow outbound traffic to instances on the health check port."
    #     protocol    = "tcp"
    #     from_port   = 1
    #     to_port     = 65535
    #
    #     cidr_blocks = "0.0.0.0/0"
    #   },
    # ]
  )

  revoke_rules_on_delete = true
  resource_group_enabled = false
  module_tags_enabled    = false

  tags = merge(
    local.module_tags,
    var.tags,
  )
}
