variable "name" {
  description = "(Required) The name of the load balancer. This name must be unique within your AWS account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen."
  type        = string
  nullable    = false

  validation {
    condition     = length(var.name) <= 32
    error_message = "The name can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen."
  }
}

variable "is_public" {
  description = "(Optional) Indicates whether the load balancer will be public. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "ip_address_type" {
  description = "(Optional) The type of IP addresses used by the subnets for your load balancer. The possible values are `IPV4` and `DUALSTACK`."
  type        = string
  default     = "IPV4"
  nullable    = false

  validation {
    condition     = contains(["IPV4", "DUALSTACK"], var.ip_address_type)
    error_message = "The possible values are `IPV4` and `DUALSTACK`."
  }
}

variable "network_mapping" {
  description = <<EOF
  (Optional) The configuration for the load balancer how routes traffic to targets in which subnets, and in accordance with IP address settings. Select at least one Availability Zone and one subnet for each zone. We recommend selecting at least two Availability Zones. The load balancer will route traffic only to targets in the selected Availability Zones. Zones that are not supported by the load balancer or VPC cannot be selected. Subnets can be added, but not removed, once a load balancer is created. Each key of `network_mapping` is the availability zone id like `apne2-az1`, `use1-az1`. Each value of `network_mapping` block as defined below.
    (Required) `subnet` - The id of the subnet of which to attach to the load balancer. You can specify only one subnet per Availability Zone.
    (Optional) `private_ipv4_address` - A private ipv4 address within the subnet to assign to the internal load balancer.
    (Optional) `ipv6_address` - An ipv6 address within the subnet to assign to the internet-facing load balancer.
    (Optional) `elastic_ip` - The allocation ID of the Elastic IP address.
  EOF
  type = map(object({
    subnet               = string
    private_ipv4_address = optional(string)
    ipv6_address         = optional(string)
    elastic_ip           = optional(string)
  }))
  default  = {}
  nullable = false
}

variable "security_group_evaluation_on_privatelink_enabled" {
  description = "(Optional) Whether to evaluate inbound security group rules for traffic sent to a Network Load Balancer through AWS PrivateLink. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "default_security_group" {
  description = <<EOF
  (Optional) The configuration of the default security group for the load balancer. `default_security_group` block as defined below.
    (Optional) `enabled` - Whether to use the default security group. Defaults to `true`.
    (Optional) `name` - The name of the default security group. If not provided, the load balancer name is used for the name of security group.
    (Optional) `description` - The description of the default security group.
    (Optional) `ingress_rules` - A list of ingress rules in a security group. Defaults to `[]`. Each block of `ingress_rules` as defined below.
      (Required) `id` - The ID of the ingress rule. This value is only used internally within Terraform code.
      (Optional) `description` - The description of the rule.
      (Required) `protocol` - The protocol to match. Note that if `protocol` is set to `-1`, it translates to all protocols, all port ranges, and `from_port` and `to_port` values should not be defined.
      (Required) `from_port` - The start of port range for the protocols.
      (Required) `to_port` - The end of port range for the protocols.
      (Optional) `ipv4_cidrs` - The IPv4 network ranges to allow, in CIDR notation.
      (Optional) `ipv6_cidrs` - The IPv6 network ranges to allow, in CIDR notation.
      (Optional) `prefix_lists` - The prefix list IDs to allow.
      (Optional) `security_groups` - The source security group IDs to allow.
      (Optional) `self` - Whether the security group itself will be added as a source to this ingress rule.
    (Optional) `egress_rules` - A list of egress rules in a security group. Defaults to `[{ id = "default", protocol = -1, from_port = 1, to_port=65535, ipv4_cidrs = ["0.0.0.0/0"] }]`. Each block of `egress_rules` as defined below.
      (Required) `id` - The ID of the egress rule. This value is only used internally within Terraform code.
      (Optional) `description` - The description of the rule.
      (Required) `protocol` - The protocol to match. Note that if `protocol` is set to `-1`, it translates to all protocols, all port ranges, and `from_port` and `to_port` values should not be defined.
      (Required) `from_port` - The start of port range for the protocols.
      (Required) `to_port` - The end of port range for the protocols.
      (Optional) `ipv4_cidrs` - The IPv4 network ranges to allow, in CIDR notation.
      (Optional) `ipv6_cidrs` - The IPv6 network ranges to allow, in CIDR notation.
      (Optional) `prefix_lists` - The prefix list IDs to allow.
      (Optional) `security_groups` - The source security group IDs to allow.
      (Optional) `self` - Whether the security group itself will be added as a source to this ingress rule.
    (Optional) `listener_ingress_ipv4_cidrs` - A list of IPv4 CIDR ranges to allow on the listener port. Defaults to `[]`."
    (Optional) `listener_ingress_ipv6_cidrs` - A list of IPv6 CIDR ranges to allow on the listener port. Defaults to `[]`."
    (Optional) `listener_ingress_prefix_lists` - A list of prefix list IDs for AWS services to allow on the listener port. Defaults to `[]`."
    (Optional) `listener_ingress_security_groups` - A list of security group IDs to allow on the listener port. Defaults to `[]`."
  EOF
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string)
    description = optional(string, "Managed by Terraform.")
    ingress_rules = optional(
      list(object({
        id              = string
        description     = optional(string, "Managed by Terraform.")
        protocol        = string
        from_port       = number
        to_port         = number
        ipv4_cidrs      = optional(list(string), [])
        ipv6_cidrs      = optional(list(string), [])
        prefix_lists    = optional(list(string), [])
        security_groups = optional(list(string), [])
        self            = optional(bool, false)
      })),
      []
    )
    egress_rules = optional(
      list(object({
        id              = string
        description     = optional(string, "Managed by Terraform.")
        protocol        = string
        from_port       = number
        to_port         = number
        ipv4_cidrs      = optional(list(string), [])
        ipv6_cidrs      = optional(list(string), [])
        prefix_lists    = optional(list(string), [])
        security_groups = optional(list(string), [])
        self            = optional(bool, false)
      })),
      [{
        id          = "default"
        description = "Allow all outbound traffic."
        protocol    = "-1"
        from_port   = 1
        to_port     = 65535
        ipv4_cidrs  = ["0.0.0.0/0"]
      }]
    )
    listener_ingress_ipv4_cidrs      = optional(list(string), [])
    listener_ingress_ipv6_cidrs      = optional(list(string), [])
    listener_ingress_prefix_lists    = optional(list(string), [])
    listener_ingress_security_groups = optional(list(string), [])
  })
  default  = {}
  nullable = false
}

variable "security_groups" {
  description = "(Optional) A list of security group IDs to assign to the Load Balancer. Security groups for Network Load Balancer cannot be added if none are currently present, and cannot all be removed once added. If either of these conditions are met, this will force a recreation of the resource."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "access_log" {
  description = <<EOF
  (Optional) A configuration for the access logs for the load balancer. Access logs deliver detailed logs of all requests made to your Elastic Load Balancer. `access_log` as defined below.
    (Optional) `enabled` - Indicates whether to enable access logs. Defaults to `false`.
    (Optional) `s3_bucket` - A configuration of the S3 Bucket for access logs. `s3_bucket` as defined below.
      (Required) `name` - The name of the S3 bucket used to store the access logs.
      (Optional) `key_prefix` - The key prefix for the specified S3 bucket.
  EOF
  type = object({
    enabled = optional(bool, false)
    s3_bucket = optional(object({
      name       = optional(string)
      key_prefix = optional(string, "")
    }), {})
  })
  default  = {}
  nullable = false
}

variable "route53_resolver_availability_zone_affinity" {
  description = <<EOF
  (Optional) A configuration to determine how traffic is distributed among the load balancer Availability Zones. Only applied to internal requests for clients resolving the load balancer DNS name using Route 53 Resolver. Valid values are `ANY`, `PARTIAL`, `ALL`. Defaults to `ANY`.
    `ANY` - Client DNS queries will resolve to healthy load balancer IP addresses across all load balancer Availability Zones.
    `PARTIAL` - 85% of client DNS queries will favor load balancer IP addresses in their own Availability Zone. The remaining queries will resolve to any zone. Resolving to any zone may also occur if there are no healthy load balancer IP addresses in the client's zone.
    `ALL` - Client DNS queries will favor load balancer IP addresses in their own Availability Zone. Queries may resolve to other zones if there are no healthy load balancer IP addresses in their own zone.
  balancer Availability Zones.
  EOF
  type        = string
  default     = "ANY"
  nullable    = false

  validation {
    condition     = contains(["ANY", "PARTIAL", "ALL"], var.route53_resolver_availability_zone_affinity)
    error_message = "Valid values are `ANY`, `PARTIAL`, `ALL`."
  }
}

variable "cross_zone_load_balancing_enabled" {
  description = "(Optional) Cross-zone load balancing distributes traffic evenly across all targets in the Availability Zones enabled for the load balancer. Indicates whether to enable cross-zone load balancing. Defaults to `false`. Regional data transfer charges may apply when cross-zone load balancing is enabled."
  type        = bool
  default     = false
  nullable    = false
}

variable "deletion_protection_enabled" {
  description = "(Optional) Indicates whether deletion of the load balancer via the AWS API will be protected. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "listeners" {
  description = <<EOF
  (Optional) A list of listener configurations of the network load balancer. Listeners listen for connection requests using their `protocol` and `port`. Each value of `listener` block as defined below.
    (Required) `port` - The number of port on which the listener of load balancer is listening.
    (Required) `protocol` - The protocol for connections from clients to the load balancer. Valid values are `TCP`, `TLS`, `UDP` and `TCP_UDP`. Not valid to use `UDP` or `TCP_UDP` if dual-stack mode is enabled on the load balancer.
    (Required) `target_group` - The ARN of the target group to which to route traffic.
    (Optional) `tls` - The configuration for TLS listener of the load balancer. Required if `protocol` is `TLS`. `tls` block as defined below.
      (Optional) `certificate` - The ARN of the default SSL server certificate. For adding additional SSL certificates, see the `additional_certificates` variable.
      (Optional) `additional_certificates` - A set of ARNs of the certificate to attach to the listener. This is for additional certificates and does not replace the default certificate on the listener.
      (Optional) `security_policy` - The name of security policy for a Secure Socket Layer (SSL) negotiation configuration. This is used to negotiate SSL connections with clients. Required if protocol is `TLS`. Recommend using the `ELBSecurityPolicy-TLS13-1-2-2021-06` security policy. This security policy includes TLS 1.3, which is optimized for security and performance, and is backward compatible with TLS 1.2.
      (Optional) `alpn_policy` - The policy of the Application-Layer Protocol Negotiation (ALPN) to select. ALPN is a TLS extension that includes the protocol negotiation within the exchange of hello messages. Can be set if `protocol` is `TLS`. Valid values are `HTTP1Only`, `HTTP2Only`, `HTTP2Optional`, `HTTP2Preferred`, and `None`. Defaults to `None`.
  EOF
  type = list(object({
    port         = number
    protocol     = string
    target_group = string
    tls = optional(object({
      certificate             = optional(string)
      additional_certificates = optional(set(string), [])
      security_policy         = optional(string, "ELBSecurityPolicy-TLS13-1-2-2021-06")
      alpn_policy             = optional(string, "None")
    }), {})
  }))
  default  = []
  nullable = false
}

variable "timeouts" {
  description = "(Optional) How long to wait for the load balancer to be created/updated/deleted."
  type = object({
    create = optional(string, "10m")
    update = optional(string, "10m")
    delete = optional(string, "10m")
  })
  default  = {}
  nullable = false
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "module_tags_enabled" {
  description = "(Optional) Whether to create AWS Resource Tags for the module informations."
  type        = bool
  default     = true
  nullable    = false
}


###################################################
# Resource Group
###################################################




variable "resource_group" {
  description = <<EOF
  (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.
    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.
    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.
    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`.
  EOF
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string, "")
    description = optional(string, "Managed by Terraform.")
  })
  default  = {}
  nullable = false
}
