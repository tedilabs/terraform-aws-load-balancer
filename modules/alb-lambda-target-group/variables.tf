variable "name" {
  description = "(Required) Name of the target group."
  type        = string

  validation {
    condition     = length(var.name) <= 32
    error_message = "The name can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen."
  }
}

variable "target_lambda" {
  description = "(Optional) The Amazon Resource Name (ARN) of the target Lambda. If your ARN does not specify a version or alias, the latest version ($LATEST) will be used by default. ARNs that specify a version / alias do so after the function name, and are separated by a colon."
  type        = string
  default     = null
}

variable "multi_value_headers_enabled" {
  description = "(Optional) Indicates whether the request and response headers that are exchanged between the load balancer and the Lambda function include arrays of values or strings. The default is false. If the value is false and the request contains a duplicate header field name or query parameter key, the load balancer uses the last value sent by the client."
  type        = bool
  default     = false
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
