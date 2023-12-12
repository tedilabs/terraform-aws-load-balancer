variable "name" {
  description = "(Required) The name of the load balancer. This name must be unique within your AWS account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen."
  type        = string
  nullable    = false

  validation {
    condition     = length(var.name) <= 32
    error_message = "The name can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen."
  }
}

variable "is_public" {
  description = "(Optional) Indicates whether the load balancer will be public. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "ip_address_type" {
  description = "(Optional) The type of IP addresses used by the subnets for your load balancer. The possible values are `IPV4` and `DUALSTACK`."
  type        = string
  default     = "IPV4"
  nullable    = false

  validation {
    condition     = contains(["IPV4", "DUALSTACK"], var.ip_address_type)
    error_message = "The possible values are `IPV4` and `DUALSTACK`."
  }
}

variable "vpc_id" {
  description = "(Required) The ID of the VPC which the load balancer belongs to."
  type        = string
}

variable "network_mapping" {
  description = <<EOF
  (Optional) The configuration for the load balancer how routes traffic to targets in which subnets, and in accordance with IP address settings. Select at least two Availability Zone and one subnet for each zone. The load balancer will route traffic only to targets in the selected Availability Zones. Zones that are not supported by the load balancer or VPC cannot be selected. Subnets can be added, but not removed, once a load balancer is created. Each key of `network_mapping` is the availability zone id like `apne2-az1`, `use1-az1`. Each value of `network_mapping` block as defined below.
    (Required) `subnet` - The id of the subnet of which to attach to the load balancer. You can specify only one subnet per Availability Zone.
  EOF
  type = map(object({
    subnet = string
  }))
  default  = {}
  nullable = false
}

variable "default_security_group" {
  description = <<EOF
  (Optional) The configuration of the default security group for the load balancer. `default_security_group` block as defined below.
    (Optional) `enabled` - Whether to use the default security group. Defaults to `true`.
    (Optional) `name` - The name of the default security group. If not provided, the load balancer name is used for the name of security group.
    (Optional) `description` - The description of the default security group.
    (Optional) `ingress_rules` - A list of ingress rules in a security group. Defaults to `[]`. Each block of `ingress_rules` as defined below.
      (Required) `id` - The ID of the ingress rule. This value is only used internally within Terraform code.
      (Optional) `description` - The description of the rule.
      (Required) `protocol` - The protocol to match. Note that if `protocol` is set to `-1`, it translates to all protocols, all port ranges, and `from_port` and `to_port` values should not be defined.
      (Required) `from_port` - The start of port range for the protocols.
      (Required) `to_port` - The end of port range for the protocols.
      (Optional) `ipv4_cidrs` - The IPv4 network ranges to allow, in CIDR notation.
      (Optional) `ipv6_cidrs` - The IPv6 network ranges to allow, in CIDR notation.
      (Optional) `prefix_lists` - The prefix list IDs to allow.
      (Optional) `security_groups` - The source security group IDs to allow.
      (Optional) `self` - Whether the security group itself will be added as a source to this ingress rule.
    (Optional) `egress_rules` - A list of egress rules in a security group. Defaults to `[{ id = "default", protocol = -1, from_port = 1, to_port=65535, ipv4_cidrs = ["0.0.0.0/0"] }]`. Each block of `egress_rules` as defined below.
      (Required) `id` - The ID of the egress rule. This value is only used internally within Terraform code.
      (Optional) `description` - The description of the rule.
      (Required) `protocol` - The protocol to match. Note that if `protocol` is set to `-1`, it translates to all protocols, all port ranges, and `from_port` and `to_port` values should not be defined.
      (Required) `from_port` - The start of port range for the protocols.
      (Required) `to_port` - The end of port range for the protocols.
      (Optional) `ipv4_cidrs` - The IPv4 network ranges to allow, in CIDR notation.
      (Optional) `ipv6_cidrs` - The IPv6 network ranges to allow, in CIDR notation.
      (Optional) `prefix_lists` - The prefix list IDs to allow.
      (Optional) `security_groups` - The source security group IDs to allow.
      (Optional) `self` - Whether the security group itself will be added as a source to this ingress rule.
    (Optional) `listener_ingress_ipv4_cidrs` - A list of IPv4 CIDR ranges to allow on the listener port. Defaults to `[]`."
    (Optional) `listener_ingress_ipv6_cidrs` - A list of IPv6 CIDR ranges to allow on the listener port. Defaults to `[]`."
    (Optional) `listener_ingress_prefix_lists` - A list of prefix list IDs for AWS services to allow on the listener port. Defaults to `[]`."
    (Optional) `listener_ingress_security_groups` - A list of security group IDs to allow on the listener port. Defaults to `[]`."
  EOF
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string)
    description = optional(string, "Managed by Terraform.")
    ingress_rules = optional(
      list(object({
        id              = string
        description     = optional(string, "Managed by Terraform.")
        protocol        = string
        from_port       = number
        to_port         = number
        ipv4_cidrs      = optional(list(string), [])
        ipv6_cidrs      = optional(list(string), [])
        prefix_lists    = optional(list(string), [])
        security_groups = optional(list(string), [])
        self            = optional(bool, false)
      })),
      []
    )
    egress_rules = optional(
      list(object({
        id              = string
        description     = optional(string, "Managed by Terraform.")
        protocol        = string
        from_port       = number
        to_port         = number
        ipv4_cidrs      = optional(list(string), [])
        ipv6_cidrs      = optional(list(string), [])
        prefix_lists    = optional(list(string), [])
        security_groups = optional(list(string), [])
        self            = optional(bool, false)
      })),
      [{
        id          = "default"
        description = "Allow all outbound traffic."
        protocol    = "-1"
        from_port   = 1
        to_port     = 65535
        ipv4_cidrs  = ["0.0.0.0/0"]
      }]
    )
    listener_ingress_ipv4_cidrs      = optional(list(string), [])
    listener_ingress_ipv6_cidrs      = optional(list(string), [])
    listener_ingress_prefix_lists    = optional(list(string), [])
    listener_ingress_security_groups = optional(list(string), [])
  })
  default  = {}
  nullable = false
}

variable "security_groups" {
  description = "(Optional) A list of security group IDs to assign to the Load Balancer."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "access_log" {
  description = <<EOF
  (Optional) A configuration for the access logs for the load balancer. Access logs deliver detailed logs of all requests made to your Elastic Load Balancer. `access_log` as defined below.
    (Optional) `enabled` - Indicates whether to enable access logs. Defaults to `false`.
    (Optional) `s3_bucket` - A configuration of the S3 Bucket for access logs. `s3_bucket` as defined below.
      (Required) `name` - The name of the S3 bucket used to store the access logs.
      (Optional) `key_prefix` - The key prefix for the specified S3 bucket.
  EOF
  type = object({
    enabled = optional(bool, false)
    s3_bucket = optional(object({
      name       = optional(string)
      key_prefix = optional(string, "")
    }), {})
  })
  default  = {}
  nullable = false
}

variable "cross_zone_load_balancing_enabled" {
  description = "(Optional) Cross-zone load balancing distributes traffic evenly across all targets in the Availability Zones enabled for the load balancer. Cross-zone load balancing is always on for Application Load Balancers. However, you can turn it off for a specific target group using target group attributes. Defaults to `true`."
  type        = bool
  default     = true
  nullable    = false

  validation {
    condition     = var.cross_zone_load_balancing_enabled == true
    error_message = "Cross-zone load balancing is always on for Application Load Balancers. However, you can turn it off for a specific target group using target group attributes."
  }
}

variable "desync_mitigation_mode" {
  description = "(Optional) Determines how the load balancer handles requests that might pose a security risk to your application. Valid values are `DEFENSIVE`, `STRICTEST` and `MONITOR`. Defaults to `DEFENSIVE`."
  type        = string
  default     = "DEFENSIVE"
  nullable    = false

  validation {
    condition     = contains(["DEFENSIVE", "STRICTEST", "MONITOR"], var.desync_mitigation_mode)
    error_message = "The possible values are `DEFENSIVE`, `STRICTEST` and `MONITOR`."
  }
}

variable "drop_invalid_header_fields" {
  description = "(Optional) Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false). Elastic Load Balancing requires that message header names contain only alphanumeric characters and hyphens. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "deletion_protection_enabled" {
  description = "(Optional) Indicates whether deletion of the load balancer via the AWS API will be protected. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "http2_enabled" {
  description = "(Optional) Indicates whether HTTP/2 is enabled. Defaults to `true`."
  type        = bool
  default     = true
  nullable    = false
}

variable "waf_fail_open_enabled" {
  description = "(Optional) Indicates whether to allow a WAF-enabled load balancer to route requests to targets if it is unable to forward the request to AWS WAF. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "idle_timeout" {
  description = "(Optional) The number of seconds before the load balancer determines the connection is idle and closes it. Defaults to `60`"
  type        = number
  default     = 60
  nullable    = false
}

variable "preserve_host_header" {
  description = "(Optional) Indicates whether the Application Load Balancer should preserve the Host header in the HTTP request and send it to the target without any change. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "tls_negotiation_headers_enabled" {
  description = "(Optional) Whether the two TLS negotiation headers (`x-amzn-tls-version` and `x-amzn-tls-cipher-suite`), which contain information about the negotiated TLS version and cipher suite, are added to the client request before sending it to the target. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "xff_header" {
  description = <<EOF
  (Optional) The configuration for . `xff_header` block as defined below.
    (Optional) `mode` - How the load balancer modifies the `X-Forwarded-For` header in the HTTP request before sending the request to the target. Valid values are `APPEND`, `PRESERVE`, `REMOVE`. Defaults to `APPEND`.
      `APPEND` - The load balancer appends the IP address of the client to the `X-Forwarded-For` header.
      `PRESERVE` - The load balancer preserves the original IP address of the client.
      `REMOVE` - The load balancer removes the `X-Forwarded-For` header from the request.
    (Optional) `client_port_preservation_enabled` - Whether the `X-Forwarded-For` header should preserve the source port that the client used to connect to the load balancer. Defaults to `false`.
  EOF
  type = object({
    mode                             = optional(string, "APPEND")
    client_port_preservation_enabled = optional(bool, false)
  })
  default  = {}
  nullable = false

  validation {
    condition     = contains(["APPEND", "PRESERVE", "REMOVE"], var.xff_header.mode)
    error_message = "Valid values of `xff_header.mode` are `APPEND`, `PRESERVE`, `REMOVE`."
  }
}

variable "listeners" {
  description = <<EOF
  (Optional) A list of listener configurations of the application load balancer. Listeners listen for connection requests using their `protocol` and `port`. Each value of `listener` block as defined below.
    (Required) `port` - The number of port on which the listener of load balancer is listening.
    (Required) `protocol` - The protocol for connections from clients to the load balancer. Valid values are `HTTP` and `HTTPS`.
    (Required) `default_action_type` - The type of default routing action. Valid values are `FORWARD`, `FIXED_RESPONSE`, `REDIRECT_301` and `REDIRECT_302`.
    (Optional) `default_action_parameters` - Configuration block for the parameters of the default routing action.
    (Optional) `rules` - The rules that you define for the listener determine how the load balancer routes requests to the targets in one or more target groups.
    (Optional) The configuration for TLS listener of the load balancer. Required if `protocol` is `HTTPS`. `tls` block as defined below.
      (Optional) `certificate` - The ARN of the default SSL server certificate. For adding additional SSL certificates, see the `additional_certificates` variable.
      (Optional) `additional_certificates` - A set of ARNs of the certificate to attach to the listener. This is for additional certificates and does not replace the default certificate on the listener.
      (Optional) `security_policy` - The name of security policy for a Secure Socket Layer (SSL) negotiation configuration. This is used to negotiate SSL connections with clients. Required if protocol is `HTTPS`. Defaults to `ELBSecurityPolicy-2016-08` security policy. The `ELBSecurityPolicy-2016-08` security policy is always used for backend connections. Application Load Balancers do not support custom security policies.
  EOF
  type        = any
  # type = list(object({
  #   port                      = number
  #   protocol                  = string
  #   default_action_type       = string
  #   default_action_parameters = optional(any, {})
  #   rules                     = optional(any, {})
  #   tls = optional(object({
  #     certificate             = optional(string)
  #     additional_certificates = optional(set(string), [])
  #     security_policy         = optional(string, "ELBSecurityPolicy-2016-08")
  #   }), {})
  # }))
  default  = []
  nullable = false
}

variable "timeouts" {
  description = "(Optional) How long to wait for the load balancer to be created/updated/deleted."
  type = object({
    create = optional(string, "10m")
    update = optional(string, "10m")
    delete = optional(string, "10m")
  })
  default  = {}
  nullable = false
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
}
