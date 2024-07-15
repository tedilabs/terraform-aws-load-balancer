variable "name" {
  description = "(Required) Name of the target group. A maximum of 32 alphanumeric characters including hyphens are allowed, but the name must not begin or end with a hyphen."
  type        = string
  nullable    = false

  validation {
    condition     = length(var.name) <= 32
    error_message = "The name can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen."
  }
}

variable "vpc_id" {
  description = "(Required) The ID of the VPC which the target group belongs to."
  type        = string
}

variable "ip_address_type" {
  description = "(Required) The type of IP addresses used by the target group. Valid values are `IPV4` or `IPV6`."
  type        = string
  default     = "IPV4"
  nullable    = false

  validation {
    condition     = contains(["IPV4", "IPV6"], var.ip_address_type)
    error_message = "Valid values are `IPV4` or `IPV6`."
  }
}

variable "port" {
  description = "(Required) The number of port on which targets receive traffic, unless overridden when registering a specific target. Valid values are either ports 1-65535."
  type        = number
  nullable    = false

  validation {
    condition = alltrue([
      var.port >= 1,
      var.port <= 65535,
    ])
    error_message = "Valid values are either ports 1-65535."
  }
}

variable "protocol" {
  description = "(Required) The protocol to use for routing traffic to the targets. Valid values are `TCP`, `TLS`, `UDP` and `TCP_UDP`. Not valid to use `UDP` or `TCP_UDP` if dual-stack mode is enabled on the load balancer."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["TCP", "TLS", "UDP", "TCP_UDP"], var.protocol)
    error_message = "Valid values are `TCP`, `TLS`, `UDP` and `TCP_UDP`."
  }
}

variable "targets" {
  description = <<EOF
  (Optional) A set of targets to add to the target group. Each value of `targets` block as defined below.
    (Required) `ip_address` - Specify IP addresses from the subnets of the virtual private cloud (VPC) for the target group, the RFC 1918 range (10.0.0.0/8, 172.16.0.0/12, and 192.168.0.0/16), and the RFC 6598 range (100.64.0.0/10). You can't specify publicly routable IP addresses. Support also IPv6 addresses.
    (Optional) `port` - The port on which targets receive traffic.
  EOF
  type = set(object({
    ip_address = string
    port       = optional(number, null)
  }))
  default  = []
  nullable = false
}

variable "terminate_connection_on_deregistration" {
  description = "(Optional) Whether to terminate active connections at the end of the deregistration timeout is reached on Network Load Balancers. Enabling this setting is particularly important for `UDP` and `TCP_UDP` target groups. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "deregistration_delay" {
  description = "(Optional) The time to wait for in-flight requests to complete while deregistering a target. During this time, the state of the target is draining."
  type        = number
  default     = 300
  nullable    = false

  validation {
    condition     = var.deregistration_delay <= 3600 && var.deregistration_delay >= 0
    error_message = "Valid value range is 0 - 3600."
  }
}

variable "load_balancing" {
  description = <<EOF
  (Optional) A load balancing configuration of the target group. `load_balancing` block as defined below.
    (Optional) `cross_zone_strategy` - Determines how the load balancer routes requests across the Availability Zones. Valid values are `ENABLED`, `DISABLED` or `INHERIT`. Defaults to `INHERIT` (Use load balancer configuration).
  EOF
  type = object({
    cross_zone_strategy = optional(string, "INHERIT")
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["ENABLED", "DISABLED", "INHERIT"], var.load_balancing.cross_zone_strategy)
    error_message = "Valid values are `ENABLED`, `DISABLED` and `INHERIT`."
  }
}

variable "preserve_client_ip" {
  description = "(Optional) Whether to preserve client IP addresses and ports in the packets forwarded to targets. Client IP preservation cannot be disabled if the target group protocol is `UDP` and `TCP_UDP`. Defaults to `true`."
  type        = bool
  default     = true
  nullable    = false
}

variable "proxy_protocol_v2" {
  description = "(Optional) Whether to enable support for proxy protocol v2 on Network Load Balancers. Before you enable proxy protocol v2, make sure that your application targets can process proxy protocol headers otherwise your application might break. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "stickiness_enabled" {
  description = "(Optional) Whether to enable the type of stickiness associated with this target group. If enabled, the load balancer binds a client’s session to a specific instance within the target group. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "health_check" {
  description = <<EOF
  (Optional) Health Check configuration block. The associated load balancer periodically sends requests to the registered targets to test their status. `health_check` block as defined below.
    (Optional) `protocol` - Protocol to use to connect with the target. The possible values are `TCP`, `HTTP` and `HTTPS`. Defaults to `TCP`.
    (Optional) `port` - The port the load balancer uses when performing health checks on targets. The default is the port on which each target receives traffic from the load balancer. Valid values are either ports 1-65535.
    (Optional) `port_override` - Whether to override the port on which each target receives trafficfrom the load balancer to a different port. Defaults to `false`.
    (Optional) `path` - Use the default path of `/` to ping the root, or specify a custom path if preferred. Only valid if the `protocol` is `HTTP` or `HTTPS`.
    (Optional) `healthy_threshold` - The number of consecutive health checks successes required before considering an unhealthy target healthy. Valid value range is 2 - 10. Defaults to `3`.
    (Optional) `unhealthy_threshold` - The number of consecutive health check failures required before considering a target unhealthy. Valid value range is 2 - 10. Defaults to `3`.
    (Optional) `interval` - Approximate amount of time, in seconds, between health checks of an individual target. Valid value range is 5 - 300. Defaults to `10`.
  EOF
  type = object({
    protocol      = optional(string, "TCP")
    port          = optional(number, null)
    port_override = optional(bool, false)
    path          = optional(string, "/")

    healthy_threshold   = optional(number, 3)
    unhealthy_threshold = optional(number, 3)
    interval            = optional(number, 10)
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      contains(["TCP", "HTTP", "HTTPS"], var.health_check.protocol),
      coalesce(var.health_check.port, 80) >= 1,
      coalesce(var.health_check.port, 80) <= 65535,
      length(var.health_check.path) <= 1024,
      var.health_check.healthy_threshold <= 10,
      var.health_check.healthy_threshold >= 2,
      var.health_check.unhealthy_threshold <= 10,
      var.health_check.unhealthy_threshold >= 2,
      contains([10, 30], var.health_check.interval),
    ])
    error_message = "Not valid parameters for `health_check`."
  }
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

variable "resource_group_enabled" {
  description = "(Optional) Whether to create Resource Group to find and group AWS resources which are created by this module."
  type        = bool
  default     = true
  nullable    = false
}

variable "resource_group_name" {
  description = "(Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`."
  type        = string
  default     = ""
  nullable    = false
}

variable "resource_group_description" {
  description = "(Optional) The description of Resource Group."
  type        = string
  default     = "Managed by Terraform."
  nullable    = false
}
