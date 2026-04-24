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
  nullable    = false
}

variable "ip_address_type" {
  description = "(Optional) The type of IP addresses used by the target group. Valid values are `IPV4` or `IPV6`. Defaults to `IPV4`."
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
  description = "(Required) The protocol to use for routing traffic to the targets. Valid values are `HTTP` and `HTTPS`. Defaults to `HTTP`."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.protocol)
    error_message = "Valid values are `HTTP` and `HTTPS`."
  }
}

variable "protocol_version" {
  description = "(Optional) Use `HTTP1` to send requests to targets using HTTP/1.1. Supported when the request protocol is HTTP/1.1 or HTTP/2. Use `HTTP2` to send requests to targets using HTTP/2. Supported when the request protocol is HTTP/2 or gRPC, but gRPC-specific features are not available. Use `GRPC` to send requests to targets using gRPC. Supported when the request protocol is gRPC. Defaults to `HTTP1`."
  type        = string
  default     = "HTTP1"
  nullable    = false

  validation {
    condition     = contains(["HTTP1", "HTTP2", "GRPC"], var.protocol_version)
    error_message = "Valid values are `HTTP1`, `HTTP2` and `GRPC`."
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
    port       = optional(number)
  }))
  default  = []
  nullable = false
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
    (Optional) `algorithm` - Determines how the load balancer selects targets when routing requests. Valid values are `ROUND_ROBIN`, `LEAST_OUTSTANDING_REQUESTS` or `WEIGHTED_RANDOM`. Defaults to `ROUND_ROBIN`.
    (Optional) `anomaly_mitigation_enabled` - Whether to enable target anomaly mitigation. When a target is determined to be anomalous, traffic is automatically routed away so the target has an opportunity to recover. Target anomaly mitigation is only supported by the `WEIGHTED_RANDOM` load balancing algorithm type. Not compatible with the `slow_start_duration` attribute. Defaults to `false`.
    (Optional) `cross_zone_strategy` - Determines how the load balancer routes requests across the Availability Zones. Valid values are `ENABLED`, `DISABLED` or `INHERIT`. Defaults to `INHERIT` (Use load balancer configuration).
    (Optional) `slow_start_duration` - The amount time for a newly registered targets to warm up before the load balancer sends them a full share of requests. During this period, targets receives an increasing share of requests until it reaches its fair share. Requires `30` to `900` seconds to enable, or `0` seconds to disable. Not compatible with the Least outstanding requests and Weighted random routing algorithms. Defaults to `0`.
    (Optional) `stickiness` - A stickiness configuration for the target group. `stickiness` block as defined below.
       (Optional) `enabled` - Whether to enable the type of stickiness associated with this target group. If enabled, the load balancer binds a client’s session to a specific instance within the target group. Defaults to `false`.
       (Optional) `type` - The type of sticky sessions. Valid values are `LB_COOKIE` or `APP_COOKIE`. Defaults to `LB_COOKIE`.
       (Optional) `duration` - The time period, in seconds, during which requests from a client should be routed to the same target. After this time period expires, the load balancer-generated cookie is considered stale. Valid values are from `1` to `604800` (1 week). Defaults to `86400` (1 day).
       (Optional) `cookie` - The name of the application based cookie. `AWSALB`, `AWSALBAPP`, and `AWSALBTG` prefixes are reserved and cannot be used. Only needed when `type` is `APP_COOKIE`.
  EOF
  type = object({
    algorithm                  = optional(string, "ROUND_ROBIN")
    anomaly_mitigation_enabled = optional(bool, false)
    cross_zone_strategy        = optional(string, "INHERIT")
    slow_start_duration        = optional(number, 0)
    stickiness = optional(object({
      enabled  = optional(bool, false)
      type     = optional(string, "LB_COOKIE")
      duration = optional(number, 86400)
      cookie   = optional(string, "")
    }), {})
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["ROUND_ROBIN", "LEAST_OUTSTANDING_REQUESTS", "WEIGHTED_RANDOM"], var.load_balancing.algorithm)
    error_message = "Valid values are `ROUND_ROBIN`, `LEAST_OUTSTANDING_REQUESTS` and `WEIGHTED_RANDOM`."
  }
  validation {
    condition = anytrue([
      !var.load_balancing.anomaly_mitigation_enabled,
      var.load_balancing.algorithm == "WEIGHTED_RANDOM"
    ])
    error_message = "Target anomaly mitigation is only supported by the `WEIGHTED_RANDOM` load balancing algorithm type."
  }
  validation {
    condition     = contains(["ENABLED", "DISABLED", "INHERIT"], var.load_balancing.cross_zone_strategy)
    error_message = "Valid values are `ENABLED`, `DISABLED` and `INHERIT`."
  }
  validation {
    condition = anytrue([
      var.load_balancing.slow_start_duration == 0,
      !contains(["LEAST_OUTSTANDING_REQUESTS", "WEIGHTED_RANDOM"], var.load_balancing.algorithm),
    ])
    error_message = "The `slow_start_duration` attribute is not compatible with the Least outstanding requests and Weighted random routing algorithms."
  }
  validation {
    condition = anytrue([
      var.load_balancing.slow_start_duration == 0,
      var.load_balancing.slow_start_duration <= 900 && var.load_balancing.slow_start_duration >= 30
    ])
    error_message = "Valid value for `slow_start_duration` is 0 to disable, or from 30 to 900 to enable."
  }
  validation {
    condition     = contains(["LB_COOKIE", "APP_COOKIE"], var.load_balancing.stickiness.type)
    error_message = "Valid values for `stickiness.type` are `LB_COOKIE` or `APP_COOKIE`."
  }
  validation {
    condition = alltrue([
      var.load_balancing.stickiness.duration >= 1,
      var.load_balancing.stickiness.duration <= 604800,
    ])
    error_message = "Valid values for `stickiness.duration` are from `1` to `604800` (1 week)."
  }
  validation {
    condition = anytrue([
      var.load_balancing.stickiness.type != "APP_COOKIE",
      length(var.load_balancing.stickiness.cookie) > 0 && !can(regex("^(AWSALB|AWSALBAPP|AWSALBTG)", var.load_balancing.stickiness.cookie))
    ])
    error_message = "The `cookie` attribute is only needed when `stickiness.type` is `APP_COOKIE`, and the name of the application based cookie cannot start with `AWSALB`, `AWSALBAPP`, or `AWSALBTG`."
  }
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

variable "target_optimizer" {
  description = <<EOF
  (Optional) A configuration for the target optimizer feature of the target group. Use a target control port when the target has a strict concurrency limit. `target_optimizer` block as defined below.
    (Optional) `target_control_port` - The port on which the target control agent and application load balancer exchange management traffic for the target optimizer feature. Only valid for ALB instance/ip target groups.
  EOF
  type = object({
    target_control_port = optional(number)
  })
  default  = {}
  nullable = false
}

variable "health_check" {
  description = <<EOF
  (Optional) A configurations for Health Check of the target group. The associated load balancer periodically sends requests to the registered targets to test their status. `health_check` block as defined below.
    (Optional) `protocol` - Protocol to use to connect with the target. The possible values are `HTTP` and `HTTPS`. Defaults to `HTTP`.
    (Optional) `port` - The port the load balancer uses when performing health checks on targets. The default is the port on which each target receives traffic from the load balancer. Valid values are either ports 1-65535.
    (Optional) `port_override` - Whether to override the port on which each target receives traffic from the load balancer to a different port. Defaults to `false`.
    (Optional) `path` - The ping path for the HTTP or HTTPS protocol. Defaults to `/` if the protocol version is `HTTP1` or `HTTP2`, and `/AWS.ALB/healthcheck` if the protocol version is `GRPC`. A path can have a maximum of 1024 characters.
    (Optional) `success_codes` - The HTTP codes to use when checking for a successful response from a target. You can specify multiple values (for example, `200,202`) or a range of values (for example, `200-299`).
    (Optional) `healthy_threshold` - The number of consecutive health checks successes required before considering an unhealthy target healthy. Valid value range is 2 - 10. Defaults to `5`.
    (Optional) `unhealthy_threshold` - The number of consecutive health check failures required before considering a target unhealthy. Valid value range is 2 - 10. Defaults to `2`.
    (Optional) `interval` - Approximate amount of time, in seconds, between health checks of an individual target. Valid value range is 5 - 300. Defaults to `30`.
    (Optional) `timeout` - The amount of time, in seconds, during which no response means a failed health check. Valid value range is 2 - 120. Defaults to `5`.
  EOF
  type = object({
    protocol      = optional(string, "HTTP")
    port          = optional(number)
    port_override = optional(bool, false)
    path          = optional(string, "")
    success_codes = optional(string)

    healthy_threshold   = optional(number, 5)
    unhealthy_threshold = optional(number, 2)
    interval            = optional(number, 30)
    timeout             = optional(number, 5)
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.health_check.protocol)
    error_message = "Valid values for `protocol` are `HTTP` and `HTTPS`."
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
    condition = alltrue([
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
