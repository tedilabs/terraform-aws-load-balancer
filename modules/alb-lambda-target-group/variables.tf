variable "name" {
  description = "(Required) Name of the target group."
  type        = string

  validation {
    condition     = length(var.name) <= 32
    error_message = "The name can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen."
  }
}

variable "targets" {
  description = <<EOF
  (Optional) A list of targets to add to the target group. The Lambda target group is limited to a single Lambda function target. The load balancer starts routing requests to a newly registered target as soon as the registration process completes and the target passes the initial health checks (if enabled). Each value of `targets` block as defined below.
    (Required) `lambda_function` - The Amazon Resource Name (ARN) of the target Lambda. If your ARN does not specify a version or alias, the latest version ($LATEST) will be used by default. ARNs that specify a version / alias do so after the function name, and are separated by a colon.
  EOF
  type        = list(map(string))
  default     = []

  validation {
    condition     = length(var.targets) <= 1
    error_message = "The Lambda target group is limited to a single Lambda function target."
  }
}

variable "multi_value_headers_enabled" {
  description = "(Optional) Indicates whether the request and response headers that are exchanged between the load balancer and the Lambda function include arrays of values or strings. Defaults to `false`. If the value is false and the request contains a duplicate header field name or query parameter key, the load balancer uses the last value sent by the client."
  type        = bool
  default     = false
}

variable "health_check" {
  description = <<EOF
  (Optional) Health Check configuration block. The associated load balancer periodically sends requests to the registered targets to test their status. `health_check` block as defined below.
    (Optional) `enabled` - Whether health checks are enabled. Health checks count as a request for your Lambda function. Defaults to `false`.
    (Optional) `healthy_threshold` - The number of consecutive health checks successes required before considering an unhealthy target healthy. Valid value range is 2 - 10. Defaults to `5`.
    (Optional) `unhealthy_threshold` - The number of consecutive health check failures required before considering a target unhealthy. Valid value range is 2 - 10. Defaults to `2`.
    (Optional) `interval` - Approximate amount of time, in seconds, between health checks of an individual target. Valid value range is 5 - 300. Defaults to `35`.
    (Optional) `timeout` - The amount of time, in seconds, during which no response means a failed health check. Valid value range is 2 - 120. Defaults to `30`.
    (Optional) `success_codes` - The HTTP codes to use when checking for a successful response from a target. You can specify multiple values (for example, `200,202`) or a range of values (for example, `200-299`). Defaults to `200`.
    (Optional) `path` - Use the default path of `/` to ping the root, or specify a custom path if preferred.
  EOF
  type        = any
  default     = {}

  validation {
    condition = alltrue([
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
