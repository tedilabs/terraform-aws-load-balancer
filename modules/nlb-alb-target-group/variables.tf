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
  description = "(Optional) The port number on which the targets receive traffic. Valid values are either ports 1-65535."
  type        = number

  validation {
    condition = alltrue([
      var.port >= 1,
      var.port <= 65535,
    ])
    error_message = "Valid values are either ports 1-65535."
  }
}

variable "targets" {
  description = <<EOF
  (Optional) A list of targets to add to the target group. The ALB target group is limited to a single Application Load Balancer target. Each value of `targets` block as defined below.
    (Required) `alb` - The Amazon Resource Name (ARN) of the target ALB (Application Load Balancer).
  EOF
  type        = list(map(string))
  default     = []

  validation {
    condition     = length(var.targets) <= 1
    error_message = "The ALB target group is limited to a single Application Load Balancer target."
  }
}

variable "health_check" {
  description = <<EOF
  (Optional) Health Check configuration block. The associated load balancer periodically sends requests to the registered targets to test their status. `health_check` block as defined below.
    (Optional) `port` - The port the load balancer uses when performing health checks on targets. The default is the port on which each target receives traffic from the load balancer. Valid values are either ports 1-65535.
    (Optional) `protocol` - Protocol to use to connect with the target. The possible values are `HTTP` and `HTTPS`. Defaults to `HTTP`.
    (Optional) `healthy_threshold` - The number of consecutive health checks successes required before considering an unhealthy target healthy. Valid value range is 2 - 10. Defaults to `3`.
    (Optional) `unhealthy_threshold` - The number of consecutive health check failures required before considering a target unhealthy. Valid value range is 2 - 10. Defaults to `3`.
    (Optional) `interval` - Approximate amount of time, in seconds, between health checks of an individual target. Valid value range is 5 - 300. Defaults to `10`.
    (Optional) `timeout` - The amount of time, in seconds, during which no response means a failed health check. Valid value range is 2 - 120. Defaults to `6` when the `protocol` is `HTTP`, and `10` when the `protocol` is `HTTPS`.
    (Optional) `path` - Use the default path of `/` to ping the root, or specify a custom path if preferred. Only valid if the `protocol` is `HTTP` or `HTTPS`.
  EOF
  type        = any
  default     = {}

  validation {
    condition = alltrue([
      try(var.health_check.port, 80) >= 1,
      try(var.health_check.port, 80) <= 65535,
      contains(["HTTP", "HTTPS"], try(var.health_check.protocol, "HTTP")),
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
