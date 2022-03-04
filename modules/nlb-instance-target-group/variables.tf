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
  description = "(Required) The protocol to use for routing traffic to the targets. Valid values are `TCP`, `TLS`, `UDP` and `TCP_UDP`. Not valid to use `UDP` or `TCP_UDP` if dual-stack mode is enabled on the load balancer."
  type        = string

  validation {
    condition     = contains(["TCP", "TLS", "UDP", "TCP_UDP"], var.protocol)
    error_message = "Valid values are `TCP`, `TLS`, `UDP` and `TCP_UDP`."
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

variable "terminate_connection_on_deregistration" {
  description = "(Optional) Whether to terminate active connections at the end of the deregistration timeout is reached on Network Load Balancers. Enabling this setting is particularly important for `UDP` and `TCP_UDP` target groups. Defaults to `false`."
  type        = bool
  default     = false
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

variable "preserve_client_ip" {
  description = "(Optional) Whether to preserve client IP addresses and ports in the packets forwarded to targets. Client IP preservation cannot be disabled if the target group protocol is `UDP` and `TCP_UDP`. Defaults to `true`."
  type        = bool
  default     = true
}

variable "proxy_protocol_v2" {
  description = "(Optional) Whether to enable support for proxy protocol v2 on Network Load Balancers. Before you enable proxy protocol v2, make sure that your application targets can process proxy protocol headers otherwise your application might break. Defaults to `false`."
  type        = bool
  default     = false
}

variable "stickiness_enabled" {
  description = "(Optional) Whether to enable the type of stickiness associated with this target group. If enabled, the load balancer binds a client’s session to a specific instance within the target group. Defaults to `false`."
  type        = bool
  default     = false
}

variable "health_check" {
  description = <<EOF
  (Optional) Health Check configuration block. The associated load balancer periodically sends requests to the registered targets to test their status. `health_check` block as defined below.
    (Optional) `port` - The port the load balancer uses when performing health checks on targets. The default is the port on which each target receives traffic from the load balancer. Valid values are either ports 1-65535.
    (Optional) `protocol` - Protocol to use to connect with the target. The possible values are `TCP`, `HTTP` and `HTTPS`. Defaults to `TCP`.
    (Optional) `healthy_threshold` - The number of consecutive health checks successes required before considering an unhealthy target healthy. Valid value range is 2 - 10. Defaults to `3`.
    (Optional) `unhealthy_threshold` - The number of consecutive health check failures required before considering a target unhealthy. Valid value range is 2 - 10. Defaults to `3`.
    (Optional) `interval` - Approximate amount of time, in seconds, between health checks of an individual target. Valid value range is 5 - 300. Defaults to `10`.
    (Optional) `timeout` - The amount of time, in seconds, during which no response means a failed health check. Valid value range is 2 - 120. Defaults to `6` when the `protocol` is `HTTP`, and `10` when the `protocol` is `TCP` or `HTTPS`.
    (Optional) `path` - Use the default path of `/` to ping the root, or specify a custom path if preferred. Only valid if the `protocol` is `HTTP` or `HTTPS`.
  EOF
  type        = any
  default     = {}

  validation {
    condition = alltrue([
      try(var.health_check.port, 80) >= 1,
      try(var.health_check.port, 80) <= 65535,
      contains(["TCP", "HTTP", "HTTPS"], try(var.health_check.protocol, "TCP")),
      try(var.health_check.healthy_threshold, 3) <= 10,
      try(var.health_check.healthy_threshold, 3) >= 2,
      try(var.health_check.unhealthy_threshold, 3) <= 10,
      try(var.health_check.unhealthy_threshold, 3) >= 2,
      contains([10, 30], try(var.health_check.interval, 30)),
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
