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

variable "default_action_type" {
  description = "(Required) The type of default routing action. Default action apply to traffic that does not meet the conditions of rules on your listener. Rules can be configured after the listener is created. Valid values are `FORWARD`, `WEIGHTED_FORWARD`, `FIXED_RESPONSE`, `REDIRECT_301` and `REDIRECT_302`."
  type        = string

  validation {
    condition     = contains(["FORWARD", "WEIGHTED_FORWARD", "FIXED_RESPONSE", "REDIRECT_301", "REDIRECT_302"], var.default_action_type)
    error_message = "Valid values are `FORWARD`, `WEIGHTED_FORWARD`, `FIXED_RESPONSE`, `REDIRECT_301` and `REDIRECT_302`."
  }
}

variable "default_action_parameters" {
  description = <<EOF
  (Optional) Configuration block for the parameters of the default routing action. `default_action_parameters` block as defined below.
    (Optional) `status_code` - The status code of HTTP response. Valid values are `2XX`, `4XX`, or `5XX`. Defaults to `503`. Only supported if `default_action_type` is `FIXED_RESPONSE`.
    (Optional) `content_type` - The value of `Content-Type` HTTP response header. Valid values are `text/plain`, `text/css`, `text/html`, `application/javascript` and `application/json`. Defaults to `text/plain`. Only supported if `default_action_type` is `FIXED_RESPONSE`.
    (Optional) `data` - The data of HTTP response body. Only supported if `default_action_type` is `FIXED_RESPONSE`.
    (Optional) `protocol` - The protocol of the redirect url. Valid values are `HTTP`, `HTTPS`, or `#{protocol}`. Defaults to `#{protocol}`. Only supported if `default_action_type` is `REDIRECT_301` or `REDIRECT_302`.
    (Optional) `host` - The hostname of the redirect url. This component is not percent-encoded. The hostname can contain `#{host}`. Defaults to `#{host}`. Only supported if `default_action_type` is `REDIRECT_301` or `REDIRECT_302`.
    (Optional) `port` - The port of the redirect url. Valid values are from `1` to `65535` or `#{port}`. Defaults to `#{port}`. Only supported if `default_action_type` is `REDIRECT_301` or `REDIRECT_302`.
    (Optional) `path` - The absolute path of the redirect url, starting with the leading `/`. This component is not percent-encoded. The path can contain `#{host}`, `#{path}`, and `#{port}`. Defaults to `/#{path}`. Only supported if `default_action_type` is `REDIRECT_301` or `REDIRECT_302`.
    (Optional) `query` - The query parameters of the redirect url, URL-encoded when necessary, but not percent-encoded. Do not include the leading `?`. Defaults to `#{query}`. Only supported if `default_action_type` is `REDIRECT_301` or `REDIRECT_302`.
    (Required) `target_group` - The ARN of the target group to which to route traffic. Use to route to a single target group. To route to one or more target groups, use `default_action_type` as `WEIGHTED_FORWARD`. Only supported if `default_action_type` is `FORWARD`.
    (Required) `targets` - A list of target configurations to route traffic. Each item of `targets` block as defined below. To route to a single target group, use `default_action_type` as `FORWARD`. Only supported if `default_action_type` is `WEIGHTED_FORWARD`.
      (Required) `target_group` - The ARN of the target group to which to route traffic.
      (Optional) `weight` - The weight to use routing traffic to `target_group`. Valid value is `0` to `999`. Defaults to `1`.
    (Optional) `stickiness_duration` - The duration of the session, in seconds, during which requests from a client should be routed to the same target group. Individual target stickiness is a configuration of the target group. Valid values are from `0` to `604800` (7 days). Specify `0` if you want to disable the stickiness. Defaults to `0`. Only supported if `default_action_type` is `WEIGHTED_FORWARD`.
  EOF
  type        = any
  default     = {}

  validation {
    condition = alltrue([
      tonumber(try(var.default_action_parameters.status_code, 503)) >= 200,
      tonumber(try(var.default_action_parameters.status_code, 503)) <= 599,
      contains(
        ["text/plain", "text/css", "text/html", "application/javascript", "application/json"],
        try(var.default_action_parameters.content_type, "text/plain")
      ),
      contains(
        ["HTTP", "HTTPS", "#{protocol}"],
        try(var.default_action_parameters.protocol, "#{protocol}")
      ),
      anytrue([
        try(var.default_action_parameters.port, "#{port}") == "#{port}",
        alltrue([
          tonumber(try(var.default_action_parameters.port, 80)) >= 1,
          tonumber(try(var.default_action_parameters.port, 80)) <= 65535,
        ]),
      ]),
      substr(try(var.default_action_parameters.path, "/#{path}"), 0, 1) == "/",
      substr(try(var.default_action_parameters.query, "#{query}"), 0, 1) != "?",
      alltrue([
        for target in try(var.default_action_parameters.targets, []) :
        alltrue([
          try(target.weight, 1) >= 0,
          try(target.weight, 1) <= 999,
        ])
      ]),
      tonumber(try(var.default_action_parameters.stickiness_duration, 0)) >= 0,
      tonumber(try(var.default_action_parameters.stickiness_duration, 0)) <= 604800,
    ])
    error_message = "Not valid parameters for `default_action_parameters`."
  }
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
