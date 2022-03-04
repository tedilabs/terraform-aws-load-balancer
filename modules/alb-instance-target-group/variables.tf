variable "name" {
  description = "(Required) Name of the target group. A maximum of 32 alphanumeric characters including hyphens are allowed, but the name must not begin or end with a hyphen."
  type        = string

  validation {
    condition     = length(var.name) <= 32
    error_message = "The name can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen."
  }
}

variable "vpc_id" {
  description = "(Required) The ID of the VPC which the target group belongs to."
  type        = string
}

variable "port" {
  description = "(Required) The number of port on which targets receive traffic, unless overridden when registering a specific target. Valid values are either ports 1-65535."
  type        = number

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

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.protocol)
    error_message = "Valid values are `HTTP` and `HTTPS`."
  }
}

variable "protocol_version" {
  description = "(Optional) Use `HTTP1` to send requests to targets using HTTP/1.1. Supported when the request protocol is HTTP/1.1 or HTTP/2. Use `HTTP2` to send requests to targets using HTTP/2. Supported when the request protocol is HTTP/2 or gRPC, but gRPC-specific features are not available. Use `GRPC` to send requests to targets using gRPC. Supported when the request protocol is gRPC. Defaults to `HTTP1`."
  type        = string
  default     = "HTTP1"

  validation {
    condition     = contains(["HTTP1", "HTTP2", "GRPC"], var.protocol_version)
    error_message = "Valid values are `HTTP1`, `HTTP2` and `GRPC`."
  }
}

variable "targets" {
  description = <<EOF
  (Optional) A set of targets to add to the target group. Each value of `targets` block as defined below.
    (Required) `instance` - This is the Instance ID for an instance, or the container ID for an ECS container.
    (Optional) `port` - The port on which targets receive traffic.
  EOF
  type        = set(map(string))
  default     = []
}

variable "deregistration_delay" {
  description = "(Optional) The time to wait for in-flight requests to complete while deregistering a target. During this time, the state of the target is draining."
  type        = number
  default     = 300

  validation {
    condition     = var.deregistration_delay <= 3600 && var.deregistration_delay >= 0
    error_message = "Valid value range is 0 - 3600."
  }
}

variable "load_balancing_algorithm" {
  description = "(Optional) Determines how the load balancer selects targets when routing requests. Valid values are `ROUND_ROBIN` or `LEAST_OUTSTANDING_REQUESTS`. Defaults to `ROUND_ROBIN`."
  type        = string
  default     = "ROUND_ROBIN"

  validation {
    condition     = contains(["ROUND_ROBIN", "LEAST_OUTSTANDING_REQUESTS"], var.load_balancing_algorithm)
    error_message = "Valid values are `ROUND_ROBIN` and `LEAST_OUTSTANDING_REQUESTS`."
  }
}

variable "slow_start_duration" {
  description = "(Optional) The amount time for a newly registered targets to warm up before the load balancer sends them a full share of requests. During this period, targets receives an increasing share of requests until it reaches its fair share. Requires `30` to `900` seconds to enable, or `0` seconds to disable. This attribute cannot be combined with the Least outstanding requests algorithm."
  type        = number
  default     = 0

  validation {
    condition = anytrue([
      var.slow_start_duration == 0,
      var.slow_start_duration <= 900 && var.slow_start_duration >= 30
    ])
    error_message = "Requires `30` to `900` seconds to enable, or `0` seconds to disable. This attribute cannot be combined with the Least outstanding requests algorithm."
  }
}

variable "stickiness_enabled" {
  description = "(Optional) Whether to enable the type of stickiness associated with this target group. If enabled, the load balancer binds a client’s session to a specific instance within the target group. Defaults to `false`."
  type        = bool
  default     = false
}

variable "stickiness_type" {
  description = "(Optional) The type of sticky sessions. Valid values are `LB_COOKIE` or `APP_COOKIE`. Defaults to `LB_COOKIE`."
  type        = string
  default     = "LB_COOKIE"

  validation {
    condition     = contains(["LB_COOKIE", "APP_COOKIE"], var.stickiness_type)
    error_message = "Valid values are `LB_COOKIE` or `APP_COOKIE`."
  }
}

variable "stickiness_duration" {
  description = "(Optional) The time period, in seconds, during which requests from a client should be routed to the same target. After this time period expires, the load balancer-generated cookie is considered stale. Valid values are from `1` to `604800` (1 week). Defaults to `86400` (1 day)."
  type        = number
  default     = 86400

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
    (Optional) `port` - The port the load balancer uses when performing health checks on targets. The default is the port on which each target receives traffic from the load balancer. Valid values are either ports 1-65535.
    (Optional) `protocol` - Protocol to use to connect with the target. The possible values are `HTTP` and `HTTPS`. Defaults to `HTTP`.
    (Optional) `healthy_threshold` - The number of consecutive health checks successes required before considering an unhealthy target healthy. Valid value range is 2 - 10. Defaults to `5`.
    (Optional) `unhealthy_threshold` - The number of consecutive health check failures required before considering a target unhealthy. Valid value range is 2 - 10. Defaults to `2`.
    (Optional) `interval` - Approximate amount of time, in seconds, between health checks of an individual target. Valid value range is 5 - 300. Defaults to `30`.
    (Optional) `timeout` - The amount of time, in seconds, during which no response means a failed health check. Valid value range is 2 - 120. Defaults to `5`.
    (Optional) `success_codes` - The HTTP codes to use when checking for a successful response from a target. You can specify multiple values (for example, `200,202`) or a range of values (for example, `200-299`).
    (Optional) `path` - Use the default path of `/` to ping the root, or specify a custom path if preferred.
  EOF
  type        = any
  default     = {}

  validation {
    condition = alltrue([
      try(var.health_check.port, 80) >= 1,
      try(var.health_check.port, 80) <= 65535,
      contains(["HTTP", "HTTPS"], try(var.health_check.protocol, "HTTP")),
      try(var.health_check.healthy_threshold, 5) <= 10,
      try(var.health_check.healthy_threshold, 5) >= 2,
      try(var.health_check.unhealthy_threshold, 2) <= 10,
      try(var.health_check.unhealthy_threshold, 2) >= 2,
      try(var.health_check.interval, 30) >= 5,
      try(var.health_check.interval, 30) <= 300,
      try(var.health_check.timeout, 5) >= 2,
      try(var.health_check.timeout, 5) <= 120,
      length(try(var.health_check.path, "/")) <= 1024,
    ])
    error_message = "Not valid parameters for `health_check`."
  }
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "module_tags_enabled" {
  description = "(Optional) Whether to create AWS Resource Tags for the module informations."
  type        = bool
  default     = true
}


###################################################
# Resource Group
###################################################

variable "resource_group_enabled" {
  description = "(Optional) Whether to create Resource Group to find and group AWS resources which are created by this module."
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "(Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`."
  type        = string
  default     = ""
}

variable "resource_group_description" {
  description = "(Optional) The description of Resource Group."
  type        = string
  default     = "Managed by Terraform."
}
