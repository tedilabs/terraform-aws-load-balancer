variable "load_balancer" {
  description = "(Required) The ARN of the application load balancer to add the listener."
  type        = string
}

variable "port" {
  description = "(Required) The number of port on which the listener of load balancer is listening."
  type        = number
}

variable "protocol" {
  description = "(Required) The protocol for connections from clients to the load balancer. Valid values are `HTTP` and `HTTPS`."
  type        = string

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.protocol)
    error_message = "Valid values are `HTTP` and `HTTPS`."
  }
}

variable "target_group" {
  description = "(Required) The ARN of the target group to which to route traffic."
  type        = string
}

variable "tls_certificate" {
  description = "(Optional) The ARN of the default SSL server certificate. For adding additional SSL certificates, see the `tls_additional_certificates` variable. Required if `protocol` is `HTTPS`."
  type        = string
  default     = null
}

variable "tls_additional_certificates" {
  description = "(Optional) A set of ARNs of the certificate to attach to the listener. This is for additional certificates and does not replace the default certificate on the listener."
  type        = set(string)
  default     = []
}

# INFO: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies
variable "tls_security_policy" {
  description = "(Optional) The name of security policy for a Secure Socket Layer (SSL) negotiation configuration. This is used to negotiate SSL connections with clients. Required if protocol is `HTTPS`. Defaults to `ELBSecurityPolicy-2016-08` security policy. The `ELBSecurityPolicy-2016-08` security policy is always used for backend connections. Application Load Balancers do not support custom security policies."
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
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
