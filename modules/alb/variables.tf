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

variable "default_security_group" {
  description = <<EOF
  (Optional) The configuration of the default security group for your load balancer. `default_security_group` block as defined below.
    (Optional) `name` - The name of the default security group.
    (Optional) `description` - The description of the default security group.
    (Optional) `ingress_cidrs` - A list of IPv4 CIDR blocks to allow inbound traffic from.
    (Optional) `ingress_ipv6_cidrs` - A list of IPv6 CIDR blocks to allow inbound traffic from.
    (Optional) `ingress_prefix_lists` - A list of Prefix List IDs to allow inbound traffic from.
    (Optional) `ingress_security_groups` - A list of source Security Group IDs to allow inbound traffic from.
  EOF
  type        = any
  default     = {}
}

variable "security_groups" {
  description = "(Optional) A set of security group IDs to assign to the load balancer."
  type        = set(string)
  default     = []
}

variable "vpc_id" {
  description = "(Required) The ID of the VPC which the load balancer belongs to."
  type        = string
}

variable "network_mapping" {
  description = <<EOF
  (Optional) The configuration for the load balancer how routes traffic to targets in which subnets, and in accordance with IP address settings. Select at least two Availability Zone and one subnet for each zone. The load balancer will route traffic only to targets in the selected Availability Zones. Zones that are not supported by the load balancer or VPC cannot be selected. Subnets can be added, but not removed, once a load balancer is created. Each key of `network_mapping` is the availability zone id like `apne2-az1`, `use1-az1`. Each value of `network_mapping` block as defined below.
    (Required) `subnet_id` - The id of the subnet of which to attach to the load balancer. You can specify only one subnet per Availability Zone.
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

variable "desync_mitigation_mode" {
  description = "(Optional) Determines how the load balancer handles requests that might pose a security risk to your application. Valid values are `DEFENSIVE`, `STRICTEST` and `MONITOR`. Defaults to `DEFENSIVE`."
  type        = string
  default     = "DEFENSIVE"

  validation {
    condition     = contains(["DEFENSIVE", "STRICTEST", "MONITOR"], var.desync_mitigation_mode)
    error_message = "The possible values are `DEFENSIVE`, `STRICTEST` and `MONITOR`."
  }
}

variable "drop_invalid_header_fields" {
  description = "(Optional) Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false). Elastic Load Balancing requires that message header names contain only alphanumeric characters and hyphens. Defaults to `false`."
  type        = bool
  default     = false
}

variable "deletion_protection_enabled" {
  description = "(Optional) Indicates whether deletion of the load balancer via the AWS API will be protected. Defaults to `false`."
  type        = bool
  default     = false
}

variable "http2_enabled" {
  description = "(Optional) Indicates whether HTTP/2 is enabled. Defaults to `true`."
  type        = bool
  default     = true
}

variable "waf_fail_open_enabled" {
  description = "(Optional) Indicates whether to allow a WAF-enabled load balancer to route requests to targets if it is unable to forward the request to AWS WAF. Defaults to `false`."
  type        = bool
  default     = false
}

variable "idle_timeout" {
  description = "(Optional) The number of seconds before the load balancer determines the connection is idle and closes it. Defaults to `60`"
  type        = number
  default     = 60
}

variable "listeners" {
  description = <<EOF
  (Optional) A list of listener configurations of the application load balancer. Listeners listen for connection requests using their `protocol` and `port`. Each value of `listener` block as defined below.
    (Required) `port` - The number of port on which the listener of load balancer is listening.
    (Required) `protocol` - The protocol for connections from clients to the load balancer. Valid values are `HTTP` and `HTTPS`.
    (Required) `default_action_type` - The type of default routing action. Valid values are `FORWARD`, `FIXED_RESPONSE`, `REDIRECT_301` and `REDIRECT_302`.
    (Optional) `default_action_parameters` - Configuration block for the parameters of the default routing action.
    (Optional) `rules` - The rules that you define for the listener determine how the load balancer routes requests to the targets in one or more target groups.
    (Optional) `tls_certificate` - The ARN of the default SSL server certificate. For adding additional SSL certificates, see the `tls_additional_certificates` variable. Required if `protocol` is `HTTPS`.
    (Optional) `tls_additional_certificates` - A set of ARNs of the certificate to attach to the listener. This is for additional certificates and does not replace the default certificate on the listener.
    (Optional) `tls_security_policy` - The name of security policy for a Secure Socket Layer (SSL) negotiation configuration. This is used to negotiate SSL connections with clients. Required if protocol is `HTTPS`. Defaults to `ELBSecurityPolicy-2016-08` security policy. The `ELBSecurityPolicy-2016-08` security policy is always used for backend connections. Application Load Balancers do not support custom security policies.
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
