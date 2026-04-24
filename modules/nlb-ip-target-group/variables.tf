variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

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
  description = "(Required) The protocol to use for routing traffic to the targets. Valid values are `TCP`, `TLS`, `UDP`, `TCP_UDP`, `QUIC` and `TCP_QUIC`. Not valid to use `UDP` or `TCP_UDP` if dual-stack mode is enabled on the load balancer. Not valid to use `QUIC` or `TCP_QUIC` if security groups are configured or dual-stack mode is enabled."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["TCP", "TLS", "UDP", "TCP_UDP", "QUIC", "TCP_QUIC"], var.protocol)
    error_message = "Valid values are `TCP`, `TLS`, `UDP`, `TCP_UDP`, `QUIC` and `TCP_QUIC`. Not valid to use `UDP` or `TCP_UDP` if dual-stack mode is enabled on the load balancer. Not valid to use `QUIC` or `TCP_QUIC` if security groups are configured or dual-stack mode is enabled."
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

variable "on_deregistration" {
  description = <<EOF
  (Optional) A configuration for how Network Load Balancer handles existing connections on target deregistration events. `on_deregistration` as defined below.
    (Optional) `connection_termination_enabled` - Whether to terminate active connections at the end of the deregistration timeout is reached on Network Load Balancers. Enabling this setting is particularly important for `UDP` and `TCP_UDP` target groups. Defaults to `false`.
    (Optional) `draining_interval` - The time in seconds to wait for in-flight requests to complete when a target is deregistered if `connection_termination_enabled` is `false`. Valid values are `0` to `3600`. Defaults to `300`.
  EOF
  type = object({
    connection_termination_enabled = optional(bool, false)
    draining_interval              = optional(number, 300)
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      var.on_deregistration.draining_interval >= 0,
      var.on_deregistration.draining_interval <= 3600,
    ])
    error_message = "Valid values for `on_deregistration.draining_interval` are between `0` and `3600`."
  }
}

variable "on_unhealthy" {
  description = <<EOF
  (Optional) A configuration for how Network Load Balancer handles existing connections on target unhealthy events. `on_unhealthy` as defined below.
    (Optional) `connection_termination_enabled` - Whether to terminate connections to unhealthy targets. If `false`, maintains existing connections to unhealthy targets. No new connections are accepted. Required if the load balancer has ARC zonal shift integration enabled and cross-zone load balancing is applied. Defaults to `true`.
    (Optional) `draining_interval` - A grace period to maintain unhealthy targets in an unhealthy draining state. This state protects targets from automatic deregistration enforced on unhealthy targets if the target group is associated with an Auto Scaling group, or Elastic Container Service. Valid values are `0` to `360000`. Defaults to `0`.
  EOF
  type = object({
    connection_termination_enabled = optional(bool, true)
    draining_interval              = optional(number, 0)
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      var.on_unhealthy.draining_interval >= 0,
      var.on_unhealthy.draining_interval <= 360000,
    ])
    error_message = "Valid values for `on_unhealthy.draining_interval` are between `0` and `360000`."
  }
}

variable "load_balancing" {
  description = <<EOF
  (Optional) A load balancing configuration of the target group. `load_balancing` block as defined below.
    (Optional) `cross_zone_strategy` - Determines how the load balancer routes requests across the Availability Zones. Valid values are `ENABLED`, `DISABLED` or `INHERIT`. Defaults to `INHERIT` (Use load balancer configuration).
    (Optional) `stickiness` - A stickiness configuration for the target group. `stickiness` block as defined below.
       (Optional) `enabled` - Whether to enable the type of stickiness associated with this target group. If enabled, the load balancer binds a client’s session to a specific instance within the target group. Defaults to `false`.
  EOF
  type = object({
    cross_zone_strategy = optional(string, "INHERIT")
    stickiness = optional(object({
      enabled = optional(bool, false)
    }), {})
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["ENABLED", "DISABLED", "INHERIT"], var.load_balancing.cross_zone_strategy)
    error_message = "Valid values are `ENABLED`, `DISABLED` and `INHERIT`."
  }
}

variable "preserve_client_ip" {
  description = "(Optional) Whether to preserve client IP addresses and ports in the packets forwarded to targets. Client IP preservation cannot be disabled if the target group protocol is `UDP`, `TCP_UDP`, `QUIC` and `TCP_QUIC`. Defaults to `false` if the target group type is `IP` and the target group protocol is `TCP` or `TLS`. Otherwise, the default is `true`."
  type        = bool
  default     = null
  nullable    = true
}

variable "proxy_protocol_v2" {
  description = "(Optional) Whether to enable support for proxy protocol v2 on Network Load Balancers. Before you enable proxy protocol v2, make sure that your application targets can process proxy protocol headers otherwise your application might break. Defaults to `false`. Not supported for `QUIC` protocol."
  type        = bool
  default     = false
  nullable    = false
}

variable "dns_failover_condition" {
  description = <<EOF
  (Optional) A configuration for the DNS Failover requirements. The minimum healthy targets required to maintain the load balancer's zonal IP addresses in the DNS record, allowing for new client connections. If this requirement is not met, DNS failover is initiated. This means that the load balancer's zonal IP address is removed from the DNS record preventing the load balancer from sending new client connections to unhealthy zones. `dns_failover_condition` as defined below.
    (Optional) `min_healthy_targets` - A minimum condition for the number or percentage of healthy targets in a target group. To count as healthy, a target must pass health checks and not be part of an active zonal shift. `min_healthy_targets` as defined below.
      (Optional) `count` - The minimum number of targets that must be healthy. If the number of healthy targets is below this value, mark the zone as unhealthy in DNS, so that traffic is routed only to healthy zones. Valid values are from `0` (Disabled) to the total number of targets in the target group. Defaults to `1`.
      (Optional) `percentage` - The minimum percentage of targets that must be healthy. If the percentage of healthy targets is below this value, mark the zone as unhealthy in DNS, so that traffic is routed only to healthy zones. Valid values are from `0` to `100`. Defaults to `0` (Disabled).
  EOF
  type = object({
    min_healthy_targets = optional(object({
      count      = optional(number, 1)
      percentage = optional(number, 0)
    }), {})
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      var.dns_failover_condition.min_healthy_targets.count >= 0,
      var.dns_failover_condition.min_healthy_targets.count <= 1000,
    ])
    error_message = "Valid values for `dns_failover_condition.min_healthy_targets.count` are from `0` to `1000`."
  }
  validation {
    condition = alltrue([
      var.dns_failover_condition.min_healthy_targets.percentage >= 0,
      var.dns_failover_condition.min_healthy_targets.percentage <= 100,
    ])
    error_message = "Valid values for `dns_failover_condition.min_healthy_targets.percentage` are from `0` to `100`."
  }
}

variable "unhealthy_state_routing_condition" {
  description = <<EOF
  (Optional) A configuration for unhealthy state routing requirements. The minimum healthy targets required to deliver your service. If either the count or percentage value requirement is not met, then the unhealthy state routing action is taken. When this happens, the load balancer should fail open, sending traffic to all targets (including unhealthy targets). `unhealthy_state_routing_condition` as defined below.
    (Optional) `min_healthy_targets` - A minimum condition for the number or percentage of healthy targets in a target group. To count as healthy, a target must pass health checks and not be part of an active zonal shift. `min_healthy_targets` as defined below.
      (Optional) `count` -  The minimum number of targets that must be healthy. If the number of healthy targets is below this value, send traffic to all targets, including unhealthy targets. Valid values are from `1` to the total number of targets in the target group. Defaults to `1`.
      (Optional) `percentage` - The minimum percentage of targets that must be healthy. If the percentage of healthy targets is below this value, send traffic to all targets, including unhealthy targets. Valid values are from `0` to `100`. Defaults to `0` (Disabled).
  EOF
  type = object({
    min_healthy_targets = optional(object({
      count      = optional(number, 1)
      percentage = optional(number, 0)
    }), {})
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      var.unhealthy_state_routing_condition.min_healthy_targets.count >= 1,
      var.unhealthy_state_routing_condition.min_healthy_targets.count <= 1000,
    ])
    error_message = "Valid values for `unhealthy_state_routing_condition.min_healthy_targets.count` are from `1` to `1000`."
  }
  validation {
    condition = alltrue([
      var.unhealthy_state_routing_condition.min_healthy_targets.percentage >= 0,
      var.unhealthy_state_routing_condition.min_healthy_targets.percentage <= 100,
    ])
    error_message = "Valid values for `unhealthy_state_routing_condition.min_healthy_targets.percentage` are from `0` to `100`."
  }
  validation {
    condition = alltrue([
      var.dns_failover_condition.min_healthy_targets.count >= var.unhealthy_state_routing_condition.min_healthy_targets.count,
      var.dns_failover_condition.min_healthy_targets.percentage >= var.unhealthy_state_routing_condition.min_healthy_targets.percentage,
    ])
    error_message = "The `unhealthy_state_routing_condition` requirements should be less than or equal to the `dns_failover_condition` requirements."
  }
}

variable "health_check" {
  description = <<EOF
  (Optional) A configurations for Health Check of the target group. The associated load balancer periodically sends requests to the registered targets to test their status. `health_check` block as defined below.
    (Optional) `protocol` - Protocol to use to connect with the target. The possible values are `TCP`, `HTTP` and `HTTPS`. Defaults to `TCP`.
    (Optional) `port` - The port the load balancer uses when performing health checks on targets. The default is the port on which each target receives traffic from the load balancer. Valid values are either ports 1-65535.
    (Optional) `port_override` - Whether to override the port on which each target receives traffic from the load balancer to a different port. Defaults to `false`.
    (Optional) `path` - The ping path for the HTTP or HTTPS protocol. Defaults to `/`. A path can have a maximum of 1024 characters.
    (Optional) `success_codes` - The HTTP codes to use when checking for a successful response from a target for the HTTP or HTPS protocol. You can specify multiple values (for example, `200,202`) or a range of values (for example, `200-299`). Defaults to `200-399`.
    (Optional) `healthy_threshold` - The number of consecutive health checks successes required before considering an unhealthy target healthy. Valid value range is 2 - 10. Defaults to `5`.
    (Optional) `unhealthy_threshold` - The number of consecutive health check failures required before considering a target unhealthy. Valid value range is 2 - 10. Defaults to `2`.
    (Optional) `interval` - Approximate amount of time, in seconds, between health checks of an individual target. Valid value range is 5 - 300. Defaults to `30`.
    (Optional) `timeout` - The amount of time, in seconds, during which no response means a failed health check. Valid value range is 2 - 120. Defaults to `6` when the `protocol` is `HTTP`, and `10` when the `protocol` is `TCP` or `HTTPS`.
  EOF
  type = object({
    protocol      = optional(string, "TCP")
    port          = optional(number)
    port_override = optional(bool, false)
    path          = optional(string, "/")
    success_codes = optional(string, "200-399")

    healthy_threshold   = optional(number, 5)
    unhealthy_threshold = optional(number, 2)
    interval            = optional(number, 30)
    timeout             = optional(number)
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["TCP", "HTTP", "HTTPS"], var.health_check.protocol)
    error_message = "Valid values for `protocol` are `TCP`, `HTTP` and `HTTPS`."
  }
  validation {
    condition = anytrue([
      var.health_check.port == null,
      var.health_check.port != null && (
        var.health_check.port >= 1 &&
        var.health_check.port <= 65535
      ),
    ])
    error_message = "Valid values for `port` are either ports 1-65535."
  }
  validation {
    condition     = length(var.health_check.path) <= 1024
    error_message = "A path can have a maximum of 1024 characters."
  }
  validation {
    condition = alltrue([
      var.health_check.healthy_threshold >= 2,
      var.health_check.healthy_threshold <= 10,
    ])
    error_message = "Valid value range for `healthy_threshold` is 2 - 10."
  }
  validation {
    condition = alltrue([
      var.health_check.unhealthy_threshold >= 2,
      var.health_check.unhealthy_threshold <= 10,
    ])
    error_message = "Valid value range for `unhealthy_threshold` is 2 - 10."
  }
  validation {
    condition = alltrue([
      var.health_check.interval >= 5,
      var.health_check.interval <= 300,
    ])
    error_message = "Valid value range for `interval` is 5 - 300."
  }
  validation {
    condition = var.health_check.timeout == null || alltrue([
      var.health_check.timeout >= 2,
      var.health_check.timeout <= 120,
    ])
    error_message = "Valid value range for `timeout` is 2 - 120."
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
