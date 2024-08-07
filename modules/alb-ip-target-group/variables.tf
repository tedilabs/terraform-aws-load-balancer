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
    port       = optional(number, null)
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
  EOF
  type = object({
    algorithm                  = optional(string, "ROUND_ROBIN")
    anomaly_mitigation_enabled = optional(bool, false)
    cross_zone_strategy        = optional(string, "INHERIT")
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["ROUND_ROBIN", "LEAST_OUTSTANDING_REQUESTS", "WEIGHTED_RANDOM"], var.load_balancing.algorithm)
    error_message = "Valid values are `ROUND_ROBIN`, `LEAST_OUTSTANDING_REQUESTS` and `WEIGHTED_RANDOM`."
  }

  validation {
    condition     = contains(["ENABLED", "DISABLED", "INHERIT"], var.load_balancing.cross_zone_strategy)
    error_message = "Valid values are `ENABLED`, `DISABLED` and `INHERIT`."
  }
}

variable "slow_start_duration" {
  description = "(Optional) The amount time for a newly registered targets to warm up before the load balancer sends them a full share of requests. During this period, targets receives an increasing share of requests until it reaches its fair share. Requires `30` to `900` seconds to enable, or `0` seconds to disable. Not compatible with the Least outstanding requests and Weighted random routing algorithms."
  type        = number
  default     = 0
  nullable    = false

  validation {
    condition = anytrue([
      var.slow_start_duration == 0,
      var.slow_start_duration <= 900 && var.slow_start_duration >= 30
    ])
    error_message = "Requires `30` to `900` seconds to enable, or `0` seconds to disable. Not compatible with the Least outstanding requests and Weighted random routing algorithms."
  }
}

variable "stickiness_enabled" {
  description = "(Optional) Whether to enable the type of stickiness associated with this target group. If enabled, the load balancer binds a client’s session to a specific instance within the target group. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "stickiness_type" {
  description = "(Optional) The type of sticky sessions. Valid values are `LB_COOKIE` or `APP_COOKIE`. Defaults to `LB_COOKIE`."
  type        = string
  default     = "LB_COOKIE"
  nullable    = false

  validation {
    condition     = contains(["LB_COOKIE", "APP_COOKIE"], var.stickiness_type)
    error_message = "Valid values are `LB_COOKIE` or `APP_COOKIE`."
  }
}

variable "stickiness_duration" {
  description = "(Optional) The time period, in seconds, during which requests from a client should be routed to the same target. After this time period expires, the load balancer-generated cookie is considered stale. Valid values are from `1` to `604800` (1 week). Defaults to `86400` (1 day)."
  type        = number
  default     = 86400
  nullable    = false

  validation {
    condition = alltrue([
      var.stickiness_duration >= 1,
      var.stickiness_duration <= 604800,
    ])
    error_message = "Valid values are from `1` to `604800` (1 week)."
  }
}

variable "stickiness_cookie" {
  description = "(Optional) The name of the application based cookie. `AWSALB`, `AWSALBAPP`, and `AWSALBTG` prefixes are reserved and cannot be used. Only needed when `stickiness_type` is `APP_COOKIE`."
  type        = string
  default     = null
}

variable "health_check" {
  description = <<EOF
  (Optional) Health Check configuration block. The associated load balancer periodically sends requests to the registered targets to test their status. `health_check` block as defined below.
    (Optional) `protocol` - Protocol to use to connect with the target. The possible values are `HTTP` and `HTTPS`. Defaults to `HTTP`.
    (Optional) `port` - The port the load balancer uses when performing health checks on targets. The default is the port on which each target receives traffic from the load balancer. Valid values are either ports 1-65535.
    (Optional) `port_override` - Whether to override the port on which each target receives trafficfrom the load balancer to a different port. Defaults to `false`.
    (Optional) `path` - Use the default path of `/` to ping the root, or specify a custom path if preferred.
    (Optional) `success_codes` - The HTTP codes to use when checking for a successful response from a target. You can specify multiple values (for example, `200,202`) or a range of values (for example, `200-299`).
    (Optional) `healthy_threshold` - The number of consecutive health checks successes required before considering an unhealthy target healthy. Valid value range is 2 - 10. Defaults to `5`.
    (Optional) `unhealthy_threshold` - The number of consecutive health check failures required before considering a target unhealthy. Valid value range is 2 - 10. Defaults to `2`.
    (Optional) `interval` - Approximate amount of time, in seconds, between health checks of an individual target. Valid value range is 5 - 300. Defaults to `30`.
    (Optional) `timeout` - The amount of time, in seconds, during which no response means a failed health check. Valid value range is 2 - 120. Defaults to `5`.
  EOF
  type = object({
    protocol      = optional(string, "HTTP")
    port          = optional(number, null)
    port_override = optional(bool, false)
    path          = optional(string, null)
    success_codes = optional(string, null)

    healthy_threshold   = optional(number, 5)
    unhealthy_threshold = optional(number, 2)
    interval            = optional(number, 30)
    timeout             = optional(number, 5)
  })
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      contains(["HTTP", "HTTPS"], var.health_check.protocol),
      coalesce(var.health_check.port, 80) >= 1,
      coalesce(var.health_check.port, 80) <= 65535,
      length(var.health_check.path) <= 1024,
      var.health_check.healthy_threshold <= 10,
      var.health_check.healthy_threshold >= 2,
      var.health_check.unhealthy_threshold <= 10,
      var.health_check.unhealthy_threshold >= 2,
      var.health_check.interval >= 5,
      var.health_check.interval <= 300,
      var.health_check.timeout >= 2,
      var.health_check.timeout <= 120,
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
