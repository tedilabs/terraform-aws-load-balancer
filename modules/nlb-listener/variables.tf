variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "load_balancer" {
  description = "(Required) The ARN of the network load balancer to add the listener."
  type        = string
  nullable    = false
}

variable "port" {
  description = "(Required) The number of port on which the listener of load balancer is listening."
  type        = number
  nullable    = false
}

variable "protocol" {
  description = "(Required) The protocol for connections from clients to the load balancer. Valid values are `TCP`, `TLS`, `UDP`, `TCP_UDP`, `QUIC` and `TCP_QUIC`. Not valid to use `UDP` or `TCP_UDP` if dual-stack mode is enabled on the load balancer. Not valid to use `QUIC` or `TCP_QUIC` if security groups are configured or dual-stack mode is enabled."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["TCP", "TLS", "UDP", "TCP_UDP", "QUIC", "TCP_QUIC"], var.protocol)
    error_message = "Valid values are `TCP`, `TLS`, `UDP`, `TCP_UDP`, `QUIC` and `TCP_QUIC`. Not valid to use `UDP` or `TCP_UDP` if dual-stack mode is enabled on the load balancer. Not valid to use `QUIC` or `TCP_QUIC` if security groups are configured or dual-stack mode is enabled."
  }
}

# INFO: https://docs.aws.amazon.com/elasticloadbalancing/latest/network/create-tls-listener.html#describe-ssl-policies
variable "tls" {
  description = <<EOF
  (Optional) The configuration for TLS listener of the load balancer. Required if `protocol` is `TLS`. `tls` block as defined below.
    (Optional) `certificate` - The ARN of the default SSL server certificate. For adding additional SSL certificates, see the `additional_certificates` variable.
    (Optional) `additional_certificates` - A set of ARNs of the certificate to attach to the listener. This is for additional certificates and does not replace the default certificate on the listener.
    (Optional) `security_policy` - The name of security policy for a Secure Socket Layer (SSL) negotiation configuration. This is used to negotiate SSL connections with clients. Required if protocol is `TLS`. Recommend using the `ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09` security policy.
    (Optional) `alpn_policy` - The policy of the Application-Layer Protocol Negotiation (ALPN) to select. ALPN is a TLS extension that includes the protocol negotiation within the exchange of hello messages. Can be set if `protocol` is `TLS`. Valid values are `HTTP1Only`, `HTTP2Only`, `HTTP2Optional`, `HTTP2Preferred`, and `None`. Defaults to `None`.
  EOF
  type = object({
    certificate             = optional(string)
    additional_certificates = optional(set(string), [])
    security_policy         = optional(string, "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09")
    alpn_policy             = optional(string, "None")
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["None", "HTTP1Only", "HTTP2Only", "HTTP2Optional", "HTTP2Preferred"], var.tls.alpn_policy)
    error_message = "Valid values are `HTTP1Only`, `HTTP2Only`, `HTTP2Optional`, `HTTP2Preferred`, and `None`. Defaults to `None`."
  }
}

variable "default_action_type" {
  description = "(Required) The type of default routing action. Valid values are `FORWARD`, `WEIGHTED_FORWARD`."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["FORWARD", "WEIGHTED_FORWARD"], var.default_action_type)
    error_message = "Valid values are `FORWARD`, `WEIGHTED_FORWARD`."
  }
}

variable "default_action_parameters" {
  description = <<EOF
  (Optional) Configuration block for the parameters of the default routing action. `default_action_parameters` block as defined below.
    (Optional) `target_group` - The ARN of the target group to which to route traffic. Use to route to a single target group. To route to one or more target groups, use `default_action_type` as `WEIGHTED_FORWARD`. Only supported if `default_action_type` is `FORWARD`.
    (Optional) `targets` - A list of target configurations to route traffic. To route to a single target group, use `default_action_type` as `FORWARD`. Only supported if `default_action_type` is `WEIGHTED_FORWARD`. Each item of `targets` block as defined below.
      (Required) `target_group` - The ARN of the target group to which to route traffic.
      (Optional) `weight` - The weight to use routing traffic to `target_group`. Valid value is `0` to `999`. Defaults to `1`.
    (Optional) `stickiness_duration` - The duration of the session, in seconds, during which requests from a client should be routed to the same target group. Individual target stickiness is a configuration of the target group. Valid values are from `0` to `604800` (7 days). Specify `0` if you want to disable the stickiness. Defaults to `0`. Only supported if `default_action_type` is `WEIGHTED_FORWARD`.
  EOF
  type = object({
    target_group = optional(string)

    targets = optional(list(object({
      target_group = string
      weight       = optional(number, 1)
    })), [])
    stickiness_duration = optional(number, 0)
  })
  default  = {}
  nullable = false

  validation {
    condition = anytrue([
      var.default_action_type != "FORWARD",
      var.default_action_parameters.target_group != null
    ])
    error_message = "`default_action_parameters.target_group` is required when `default_action_type` is `FORWARD`."
  }
  validation {
    condition = anytrue([
      var.default_action_type != "WEIGHTED_FORWARD",
      length(var.default_action_parameters.targets) >= 1
    ])
    error_message = "`default_action_parameters.targets` must have at least one item when `default_action_type` is `WEIGHTED_FORWARD`."
  }
  validation {
    condition = anytrue([
      var.default_action_type != "WEIGHTED_FORWARD",
      alltrue([
        for target in var.default_action_parameters.targets :
        target.weight >= 0 && target.weight <= 999
      ])
    ])
    error_message = "Each `weight` in `default_action_parameters.targets` must be between `0` and `999` when `default_action_type` is `WEIGHTED_FORWARD`."
  }
  validation {
    condition = anytrue([
      var.default_action_type != "WEIGHTED_FORWARD",
      var.default_action_parameters.stickiness_duration >= 0 && var.default_action_parameters.stickiness_duration <= 604800
    ])
    error_message = "`default_action_parameters.stickiness_duration` is only valid when `default_action_type` is `WEIGHTED_FORWARD`, and must be between `0` and `604800`."
  }
}

variable "tcp_idle_timeout" {
  description = "(Optional) The number of seconds before the listener determines that the TCP connection is idle and closes it. Only applied when `protocol` is `TCP` or `TCP_UDP`. Valid values are `60` to `6000`. Defaults to `350`."
  type        = number
  default     = 350
  nullable    = false

  validation {
    condition     = var.tcp_idle_timeout >= 60 && var.tcp_idle_timeout <= 6000
    error_message = "Valid values for `tcp_idle_timeout` are between `60` and `6000`."
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
