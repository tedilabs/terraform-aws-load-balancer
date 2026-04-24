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

variable "targets" {
  description = <<EOF
  (Optional) A set of targets to add to the target group. Each value of `targets` block as defined below.
    (Required) `instance` - This is the Instance ID for an instance, or the container ID for an ECS container.
  EOF
  type = set(object({
    instance = string
  }))
  default  = []
  nullable = false
}

variable "deregistration_delay" {
  description = "(Optional) The time to wait for in-flight requests to complete while deregistering a target. During this time, the state of the target is draining. Valid values are from `0` to `3600` seconds. Defaults to `300` seconds."
  type        = number
  default     = 300
  nullable    = false

  validation {
    condition     = var.deregistration_delay <= 3600 && var.deregistration_delay >= 0
    error_message = "Valid value range is 0 - 3600."
  }
}

variable "target_failover" {
  description = <<EOF
  (Optional) A configuration for how Gateway Load Balancer handles existing flows on target deregistration and unhealthy events. `target_failover` as defined below.
    (Optional) `rebalance_on_deregistration` - Whether to rebalance existing flows when a target is deregistered. If `true`, the load balancer will rebalance existing flows across the remaining healthy targets. Defaults to `false`.
    (Optional) `rebalance_on_unhealthy` - Whether to rebalance existing flows when a target is marked unhealthy. If `true`, the load balancer will rebalance existing flows across the remaining healthy targets. Defaults to `false`.
  EOF
  type = object({
    rebalance_on_deregistration = optional(bool, false)
    rebalance_on_unhealthy      = optional(bool, false)
  })
  default  = {}
  nullable = false

  validation {
    condition     = var.target_failover.rebalance_on_deregistration == var.target_failover.rebalance_on_unhealthy
    error_message = "`target_failover.rebalance_on_deregistration` and `target_failover.rebalance_on_unhealthy` must be equal."
  }
}

variable "flow_stickiness" {
  description = <<EOF
  (Optional) A configuration for flow stickiness of the target group. `flow_stickiness` as defined below.
    (Optional) `type` - The type of flow stickiness. Valid values are `5-tuple`, `3-tuple` and `2-tuple`. Defaults to `5-tuple`.
      `5-tuple` - Source IP, Source Port, Destination IP, Destination Port and Transport Protocol.
      `3-tuple` - Source IP, Destination IP and Transport Protocol.
      `2-tuple` - Source IP and Destination IP.
  EOF
  type = object({
    type = optional(string, "5-tuple")
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["5-tuple", "3-tuple", "2-tuple"], var.flow_stickiness.type)
    error_message = "Valid values for `type` are `5-tuple`, `3-tuple` and `2-tuple`."
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
    (Optional) `timeout` - The amount of time, in seconds, during which no response means a failed health check. Valid value range is 2 - 120. Defaults to `5`.
  EOF
  type = object({
    protocol      = optional(string, "TCP")
    port          = optional(number)
    port_override = optional(bool, false)
    path          = optional(string, "/")
    success_codes = optional(string, "200-399")

    healthy_threshold   = optional(number, 5)
    unhealthy_threshold = optional(number, 2)
    interval            = optional(number, 10)
    timeout             = optional(number, 5)
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
