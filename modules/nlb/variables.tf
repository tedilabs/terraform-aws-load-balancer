variable "name" {
  description = "(Required) The name of the load balancer. This name must be unique within your AWS account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen."
  type        = string

  validation {
    condition     = length(var.name) <= 32
    error_message = "The name can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen."
  }
}

variable "is_public" {
  description = "(Optional) Indicates whether the load balancer will be public. Defaults to `false`."
  type        = bool
  default     = false
}

variable "ip_address_type" {
  description = "(Optional) The type of IP addresses used by the subnets for your load balancer. The possible values are `IPV4` and `DUALSTACK`."
  type        = string
  default     = "IPV4"

  validation {
    condition     = contains(["IPV4", "DUALSTACK"], var.ip_address_type)
    error_message = "The possible values are `IPV4` and `DUALSTACK`."
  }
}

variable "network_mapping" {
  description = <<EOF
  (Optional) The configuration for the load balancer how routes traffic to targets in which subnets, and in accordance with IP address settings. Select at least one Availability Zone and one subnet for each zone. We recommend selecting at least two Availability Zones. The load balancer will route traffic only to targets in the selected Availability Zones. Zones that are not supported by the load balancer or VPC cannot be selected. Subnets can be added, but not removed, once a load balancer is created. Each key of `network_mapping` is the availability zone id like `apne2-az1`, `use1-az1`. Each value of `network_mapping` block as defined below.
    (Required) `subnet_id` - The id of the subnet of which to attach to the load balancer. You can specify only one subnet per Availability Zone.
    (Optional) `private_ipv4_address` - A private ipv4 address within the subnet to assign to the internal load balancer.
    (Optional) `ipv6_address` - An ipv6 address within the subnet to assign to the internet-facing load balancer.
    (Optional) `allocation_id` - The allocation ID of the Elastic IP address.
  EOF
  type        = map(map(string))
  default     = {}
}

variable "access_log_enabled" {
  description = "(Optional) Indicates whether to enable access logs. Defaults to `false`, even when bucket is specified."
  type        = bool
  default     = false
}

variable "access_log_s3_bucket" {
  description = "(Optional) The name of the S3 bucket used to store the access logs."
  type        = string
  default     = null
}

variable "access_log_s3_key_prefix" {
  description = "(Optional) The key prefix for the specified S3 bucket."
  type        = string
  default     = null
}

variable "cross_zone_load_balancing_enabled" {
  description = "(Optional) Cross-zone load balancing distributes traffic evenly across all targets in the Availability Zones enabled for the load balancer. Indicates whether to enable cross-zone load balancing. Defaults to `false`. Regional data transfer charges may apply when cross-zone load balancing is enabled."
  type        = bool
  default     = false
}

variable "deletion_protection_enabled" {
  description = "(Optional) Indicates whether deletion of the load balancer via the AWS API will be protected. Defaults to `false`."
  type        = bool
  default     = false
}

variable "listeners" {
  description = <<EOF
  (Optional) A list of listener configurations of the network load balancer. Listeners listen for connection requests using their `protocol` and `port`. Each value of `listener` block as defined below.
    (Required) `port` - The number of port on which the listener of load balancer is listening.
    (Required) `protocol` - The protocol for connections from clients to the load balancer. Valid values are `TCP`, `TLS`, `UDP` and `TCP_UDP`. Not valid to use `UDP` or `TCP_UDP` if dual-stack mode is enabled on the load balancer.
    (Required) `target_group` - The ARN of the target group to which to route traffic.
    (Optional) `tls_certificate` - The ARN of the default SSL server certificate. For adding additional SSL certificates, see the `tls_additional_certificates` variable. Required if `protocol` is `TLS`.
    (Optional) `tls_additional_certificates` - A set of ARNs of the certificate to attach to the listener. This is for additional certificates and does not replace the default certificate on the listener.
    (Optional) `tls_security_policy` - The name of security policy for a Secure Socket Layer (SSL) negotiation configuration. This is used to negotiate SSL connections with clients. Required if protocol is `TLS`. Recommend using the `ELBSecurityPolicy-TLS13-1-2-2021-06` security policy. This security policy includes TLS 1.3, which is optimized for security and performance, and is backward compatible with TLS 1.2.
    (Optional) `tls_alpn_policy` - The policy of the Application-Layer Protocol Negotiation (ALPN) to select. ALPN is a TLS extension that includes the protocol negotiation within the exchange of hello messages. Can be set if `protocol` is `TLS`. Valid values are `HTTP1Only`, `HTTP2Only`, `HTTP2Optional`, `HTTP2Preferred`, and `None`. Defaults to `None`.
  EOF
  type        = any
  default     = []
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
