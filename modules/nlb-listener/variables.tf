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
  description = "(Required) The protocol for connections from clients to the load balancer. Valid values are `TCP`, `TLS`, `UDP` and `TCP_UDP`. Not valid to use `UDP` or `TCP_UDP` if dual-stack mode is enabled on the load balancer."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["TCP", "TLS", "UDP", "TCP_UDP"], var.protocol)
    error_message = "Valid values are `TCP`, `TLS`, `UDP` and `TCP_UDP`. Not valid to use `UDP` or `TCP_UDP` if dual-stack mode is enabled on the load balancer."
  }
}

variable "target_group" {
  description = "(Required) The ARN of the target group to which to route traffic."
  type        = string
  nullable    = false
}

# INFO: https://docs.aws.amazon.com/elasticloadbalancing/latest/network/create-tls-listener.html#describe-ssl-policies
variable "tls" {
  description = <<EOF
  (Optional) The configuration for TLS listener of the load balancer. Required if `protocol` is `TLS`. `tls` block as defined below.
    (Optional) `certificate` - The ARN of the default SSL server certificate. For adding additional SSL certificates, see the `additional_certificates` variable.
    (Optional) `additional_certificates` - A set of ARNs of the certificate to attach to the listener. This is for additional certificates and does not replace the default certificate on the listener.
    (Optional) `security_policy` - The name of security policy for a Secure Socket Layer (SSL) negotiation configuration. This is used to negotiate SSL connections with clients. Required if protocol is `TLS`. Recommend using the `ELBSecurityPolicy-TLS13-1-2-2021-06` security policy. This security policy includes TLS 1.3, which is optimized for security and performance, and is backward compatible with TLS 1.2.
    (Optional) `alpn_policy` - The policy of the Application-Layer Protocol Negotiation (ALPN) to select. ALPN is a TLS extension that includes the protocol negotiation within the exchange of hello messages. Can be set if `protocol` is `TLS`. Valid values are `HTTP1Only`, `HTTP2Only`, `HTTP2Optional`, `HTTP2Preferred`, and `None`. Defaults to `None`.
  EOF
  type = object({
    certificate             = optional(string)
    additional_certificates = optional(set(string), [])
    security_policy         = optional(string, "ELBSecurityPolicy-TLS13-1-2-2021-06")
    alpn_policy             = optional(string, "None")
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["None", "HTTP1Only", "HTTP2Only", "HTTP2Optional", "HTTP2Preferred"], var.tls.alpn_policy)
    error_message = "Valid values are `HTTP1Only`, `HTTP2Only`, `HTTP2Optional`, `HTTP2Preferred`, and `None`. Defaults to `None`."
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
