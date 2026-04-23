variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "load_balancer" {
  description = "(Required) The ARN of the application load balancer to add the listener."
  type        = string
  nullable    = false
}

variable "port" {
  description = "(Required) The number of port on which the listener of load balancer is listening."
  type        = number
  nullable    = false
}

variable "protocol" {
  description = "(Required) The protocol for connections from clients to the load balancer. Valid values are `HTTP` and `HTTPS`."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["HTTP", "HTTPS"], var.protocol)
    error_message = "Valid values are `HTTP` and `HTTPS`."
  }
}

# INFO: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies
variable "tls" {
  description = <<EOF
  (Optional) The configuration for TLS listener of the load balancer. Required if `protocol` is `HTTPS`. `tls` block as defined below.
    (Optional) `certificate` - The ARN of the default SSL server certificate. For adding additional SSL certificates, see the `additional_certificates` variable.
    (Optional) `additional_certificates` - A set of ARNs of the certificate to attach to the listener. This is for additional certificates and does not replace the default certificate on the listener.
    (Optional) `security_policy` - The name of security policy for a Secure Socket Layer (SSL) negotiation configuration. This is used to negotiate SSL connections with clients. Required if protocol is `HTTPS`. Defaults to `ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09` security policy.
  EOF
  type = object({
    certificate             = optional(string)
    additional_certificates = optional(set(string), [])
    security_policy         = optional(string, "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09")
  })
  default  = {}
  nullable = false
}

variable "mtls" {
  description = <<EOF
  (Optional) A configuration for mutual TLS authentication on the listener. Only valid when `protocol` is `HTTPS`. `mtls` as defined below.
    (Required) `mode` - The mTLS verification mode. Valid values are `OFF`, `PASSTHROUGH`, `VERIFY`.
    (Optional) `trust_store` - The ARN of the Trust Store. Required when `mode` is `VERIFY`.
    (Optional) `ignore_client_certificate_expiry` - Whether client certificate expiry is ignored. Defaults to `false`. **Warning:** Setting this to `true` allows expired client certificates and weakens security guarantees. Use only when temporarily tolerating expired certificates during rotation.
    (Optional) `advertise_trust_store_ca_names` - Whether trust-store CA certificate names are advertised. Defaults to `false`.
  EOF
  type = object({
    mode                             = optional(string, "OFF")
    trust_store                      = optional(string)
    ignore_client_certificate_expiry = optional(bool, false)
    advertise_trust_store_ca_names   = optional(bool, false)
  })
  default  = {}
  nullable = false

  validation {
    condition = anytrue([
      var.mtls.mode == "OFF",
      var.protocol == "HTTPS",
    ])
    error_message = "`mtls` configuration is only valid when `protocol` is `HTTPS`."
  }
  validation {
    condition     = contains(["OFF", "PASSTHROUGH", "VERIFY"], var.mtls.mode)
    error_message = "Valid values for `mtls.mode` are `OFF`, `PASSTHROUGH`, `VERIFY`."
  }
  validation {
    condition = anytrue([
      var.mtls.mode != "VERIFY",
      var.mtls.trust_store != null
    ])
    error_message = "`mtls.trust_store` is required when `mtls.mode` is `VERIFY`."
  }
}

variable "default_action_type" {
  description = "(Required) The type of default routing action. Default action apply to traffic that does not meet the conditions of rules on your listener. Rules can be configured after the listener is created. Valid values are `FORWARD`, `WEIGHTED_FORWARD`, `FIXED_RESPONSE`, `REDIRECT_301` and `REDIRECT_302`."
  type        = string
  nullable    = false

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
    (Optional) `target_group` - The ARN of the target group to which to route traffic. Use to route to a single target group. To route to one or more target groups, use `default_action_type` as `WEIGHTED_FORWARD`. Only supported if `default_action_type` is `FORWARD`.
    (Optional) `targets` - A list of target configurations to route traffic. To route to a single target group, use `default_action_type` as `FORWARD`. Only supported if `default_action_type` is `WEIGHTED_FORWARD`. Each item of `targets` block as defined below.
      (Required) `target_group` - The ARN of the target group to which to route traffic.
      (Optional) `weight` - The weight to use routing traffic to `target_group`. Valid value is `0` to `999`. Defaults to `1`.
    (Optional) `stickiness_duration` - The duration of the session, in seconds, during which requests from a client should be routed to the same target group. Individual target stickiness is a configuration of the target group. Valid values are from `0` to `604800` (7 days). Specify `0` if you want to disable the stickiness. Defaults to `0`. Only supported if `default_action_type` is `WEIGHTED_FORWARD`.
  EOF
  type = object({
    status_code  = optional(number, 503)
    content_type = optional(string, "text/plain")
    data         = optional(string, "")

    protocol = optional(string, "#{protocol}")
    host     = optional(string, "#{host}")
    port     = optional(string, "#{port}")
    path     = optional(string, "/#{path}")
    query    = optional(string, "#{query}")

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
      var.default_action_type != "FIXED_RESPONSE",
      alltrue([
        var.default_action_parameters.status_code >= 200,
        var.default_action_parameters.status_code <= 599,
      ])
    ])
    error_message = "`default_action_parameters.status_code` is only valid when `default_action_type` is `FIXED_RESPONSE`, and must be between `200` and `599`."
  }
  validation {
    condition = anytrue([
      var.default_action_type != "FIXED_RESPONSE",
      contains(
        ["text/plain", "text/css", "text/html", "application/javascript", "application/json"],
        var.default_action_parameters.content_type
      )
    ])
    error_message = "`default_action_parameters.content_type` is only valid when `default_action_type` is `FIXED_RESPONSE`, and valid values are `text/plain`, `text/css`, `text/html`, `application/javascript` and `application/json`."
  }
  validation {
    condition = anytrue([
      var.default_action_type != "FIXED_RESPONSE",
      length(var.default_action_parameters.data) <= 1024
    ])
    error_message = "`default_action_parameters.data` is only valid when `default_action_type` is `FIXED_RESPONSE`, and the maximum size is 1024 characters."
  }
  validation {
    condition = anytrue([
      !contains(["REDIRECT_301", "REDIRECT_302"], var.default_action_type),
      contains(["HTTP", "HTTPS", "#{protocol}"], var.default_action_parameters.protocol)
    ])
    error_message = "`default_action_parameters.protocol` is only valid when `default_action_type` is `REDIRECT_301` or `REDIRECT_302`, and valid values are `HTTP`, `HTTPS`, or `#{protocol}`."
  }
  validation {
    condition = anytrue([
      !contains(["REDIRECT_301", "REDIRECT_302"], var.default_action_type),
      anytrue([
        var.default_action_parameters.port == "#{port}",
        var.default_action_parameters.port != "#{port}" && (tonumber(var.default_action_parameters.port) >= 1 && tonumber(var.default_action_parameters.port) <= 65535),
      ])
    ])
    error_message = "`default_action_parameters.port` is only valid when `default_action_type` is `REDIRECT_301` or `REDIRECT_302`, and valid values are from `1` to `65535` or `#{port}`."
  }
  validation {
    condition = anytrue([
      !contains(["REDIRECT_301", "REDIRECT_302"], var.default_action_type),
      length(var.default_action_parameters.path) <= 128 && substr(var.default_action_parameters.path, 0, 1) == "/"
    ])
    error_message = "`default_action_parameters.path` is only valid when `default_action_type` is `REDIRECT_301` or `REDIRECT_302`, the maximum size is 128 characters, and must start with `/`."
  }
  validation {
    condition = anytrue([
      var.default_action_type != "REDIRECT_301" && var.default_action_type != "REDIRECT_302",
      substr(var.default_action_parameters.query, 0, 1) != "?",
    ])
    error_message = "`default_action_parameters.query` is only valid when `default_action_type` is `REDIRECT_301` or `REDIRECT_302`, and must not start with `?`."
  }
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

variable "rules" {
  description = <<EOF
  (Optional) The rules that you define for the listener determine how the load balancer routes requests to the targets in one or more target groups. Each rule consists of a priority, one or more actions, and one or more conditions. Each item of `rules` block as defined below.
    (Required) `priority` - The priority for the rule between `1` and `50000`. A listener can't have multiple rules with the same priority.
    (Required) `conditions` - A set of conditions of the rule. One or more condition blocks can be set per rule. Most condition types can only be specified once per rule except for `HTTP_HEADER` and `QUERY` which can be specified multiple times. All condition blocks must be satisfied for the rule to match. Each item of `conditions` block as defined below.
      (Required) `type` - The type of the condition. Valid values are `HOST`, `HTTP_METHOD`, `HTTP_HEADER`, `PATH`, `QUERY` and `SOURCE_IP`.
      (Optional) `name` - The name of HTTP header to search. The maximum size is 40 characters. Comparison is case insensitive. Only RFC7240 characters are supported. Wildcards are not supported. You cannot use HTTP header condition to specify the host header, use a `HOST` condition instead. Only required if `type` is `HTTP_HEADER`.
      (Required) `values` for `HOST` - A list of host header patterns to match. The maximum size of each pattern is 128 characters. Comparison is case insensitive. Wildcard characters supported: * (matches 0 or more characters) and ? (matches exactly 1 character). Only one pattern needs to match for the condition to be satisfied.
      (Required) `values` for `HTTP_METHOD` - A list of HTTP request methods or verbs to match. Maximum size is 40 characters. Only allowed characters are A-Z, hyphen (-) and underscore (_). Comparison is case sensitive. Wildcards are not supported. Only one needs to match for the condition to be satisfied. AWS recommends that GET and HEAD requests are routed in the same way because the response to a HEAD request may be cached.
      (Required) `values` for `HTTP_HEADER` - A list of header value patterns to match. Maximum size of each pattern is 128 characters. Comparison is case insensitive. Wildcard characters supported: * (matches 0 or more characters) and ? (matches exactly 1 character). If the same header appears multiple times in the request they will be searched in order until a match is found. Only one pattern needs to match for the condition to be satisfied. To require that all of the strings are a match, create one condition block per string.
      (Required) `values` for `PATH` - A list of path patterns to match against the request URL. Maximum size of each pattern is 128 characters. Comparison is case sensitive. Wildcard characters supported: * (matches 0 or more characters) and ? (matches exactly 1 character). Only one pattern needs to match for the condition to be satisfied. Path pattern is compared only to the path of the URL, not to its query string. To compare against the query string, use a `QUERY` condition.
      (Required) `values` for `QUERY` - A list of query string pairs to match. Each query string pair consists of `key` and `value`. Maximum size of each string is 128 characters. Comparison is case insensitive. Wildcard characters supported: * (matches 0 or more characters) and ? (matches exactly 1 character). To search for a literal '*' or '?' character in a query string, escape the character with a backslash (\). Only one pair needs to match for the condition to be satisfied.
      (Required) `values` for `SOURCE_IP` - A list of source IP CIDR notations to match. You can use both IPv4 and IPv6 addresses. Wildcards are not supported. Condition is satisfied if the source IP address of the request matches one of the CIDR blocks. Condition is not satisfied by the addresses in the `X-Forwarded-For` header, use `HTTP_HEADER` condition instead.
    (Required) `action_type` - The type of the routing action. Valid values are `FORWARD`, `WEIGHTED_FORWARD`, `FIXED_RESPONSE`, `REDIRECT_301` and `REDIRECT_302`.
    (Optional) `action_parameters` - Same with `default_action_parameters`.
    (Optional) `transforms` - A list of request transforms to apply on the rule's forwarded request. Each transform is applied in order. Each item of `transforms` block as defined below.
      (Required) `type` - The type of the transform. Valid values are `HOST_HEADER_REWRITE` and `URL_REWRITE`.
      (Required) `rewrite` - A regex-based rewrite specification. `rewrite` as defined below.
        (Required) `regex` - The regular expression used to match against the request value (Host header for `HOST_HEADER_REWRITE`, URL path for `URL_REWRITE`).
        (Required) `replace` - The replacement value to substitute into the matched portion. When `type` is `URL_REWRITE`, the replacement must start with `/`.
  EOF
  type        = any
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for rule in var.rules :
      alltrue([
        rule.priority >= 1,
        rule.priority <= 50000,
        length(rule.conditions) >= 1,
        length(rule.conditions) <= 5,
        alltrue([
          for condition in rule.conditions :
          alltrue([
            contains(["HOST", "HTTP_METHOD", "HTTP_HEADER", "PATH", "QUERY", "SOURCE_IP"], condition.type),
            length(condition.values) >= 1,
            length(condition.values) <= 5,
          ])
        ]),
        contains(["FORWARD", "WEIGHTED_FORWARD", "FIXED_RESPONSE", "REDIRECT_301", "REDIRECT_302"], rule.action_type),
        alltrue([
          for transform in try(rule.transforms, []) :
          contains(["HOST_HEADER_REWRITE", "URL_REWRITE"], transform.type)
        ]),
      ])
    ])
    error_message = "Not valid parameters for `rules`."
  }
}

variable "overwrite_response_headers" {
  description = <<EOF
  (Optional) A configuration to overwrite response headers on the listener. Valid for both `HTTP` and `HTTPS` protocol. If the HTTP response from your load balancer's target already includes a header, the load balancer will overwrite it with the configured value. `overwrite_response_headers` as defined below.
    (Optional) `strict_transport_security` - Value for the `Strict-Transport-Security` response header. Informs browsers that the site should only be accessed using HTTPS, and that any future attempts to access it using HTTP should automatically be converted to HTTPS.
    (Optional) `content_security_policy` - Value for the `Content-Security-Policy` response header. Specify restrictions enforced by the browser to help minimize the risk of certain types of security threats.
    (Optional) `x_content_type_options` - Value for the `X-Content-Type-Options` response header. Indicates whether the MIME types advertised in the `Content-Type` headers should be followed and not be changed. Valid value is `nosniff`.
    (Optional) `x_frame_options` - Value for the `X-Frame-Options` response header. Indicates whether the browser is allowed to render a page in a frame, iframe, embed or object. Valid values are `DENY`, `SAMEORIGIN`.
    (Optional) `cors` - Cross-origin resource sharing headers. `cors` as defined below.
      (Optional) `allow_origin` - Value for the `Access-Control-Allow-Origin` response header. Specifies which origins are allowed to access the server.
      (Optional) `allow_methods` - Value for the `Access-Control-Allow-Methods` response header. Specifies which HTTP methods are allowed when accessing the server from a different origin.
      (Optional) `allow_headers` - Value for the `Access-Control-Allow-Headers` response header. Specifies which headers can be used during the request.
      (Optional) `allow_credentials` - Value for the `Access-Control-Allow-Credentials` response header. Indicates whether the browser should include credentials such as cookies or authentication when making requests. Only valid value is the literal string `true`.
      (Optional) `expose_headers` - Value for the `Access-Control-Expose-Headers` response header. Indicates which headers the browser can expose to the requesting client.
      (Optional) `max_age` - Value (in seconds, as a string) for the `Access-Control-Max-Age` response header. Specify how long the results of a preflight request can be cached, in seconds.
  EOF
  type = object({
    strict_transport_security = optional(string)
    content_security_policy   = optional(string)
    x_content_type_options    = optional(string)
    x_frame_options           = optional(string)

    cors = optional(object({
      allow_origin      = optional(string)
      allow_methods     = optional(string)
      allow_headers     = optional(string)
      allow_credentials = optional(string)
      expose_headers    = optional(string)
      max_age           = optional(string)
    }), {})
  })
  default  = {}
  nullable = false

  validation {
    condition = anytrue([
      var.overwrite_response_headers.x_content_type_options == null,
      var.overwrite_response_headers.x_content_type_options == "nosniff"
    ])
    error_message = "Valid value for `overwrite_response_headers.x_content_type_options` is `nosniff`."
  }
  validation {
    condition = anytrue([
      var.overwrite_response_headers.x_frame_options == null,
      var.overwrite_response_headers.x_frame_options != null && contains(["DENY", "SAMEORIGIN"], var.overwrite_response_headers.x_frame_options),
    ])
    error_message = "Valid values for `overwrite_response_headers.x_frame_options` are `DENY` and `SAMEORIGIN`."
  }
  validation {
    condition = anytrue([
      var.overwrite_response_headers.cors.allow_credentials == null,
      var.overwrite_response_headers.cors.allow_credentials == "true"
    ])
    error_message = "Valid value for `overwrite_response_headers.cors.allow_credentials` is the literal string `true`."
  }
}

variable "server_response_header_enabled" {
  description = "(Optional) Whether to include the `Server` HTTP response header with value `awselb/2.0`. If the HTTP response from your load balancer's target already includes a header, the load balancer will not modify or remove it, regardless of these configurations. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "rename_mtls_request_headers" {
  description = <<EOF
  (Optional) A map to rename the mutual TLS client-certificate request headers that the load balancer forwards to targets. Only valid when `protocol` is `HTTPS` and `mtls.mode` is `PASSTHROUGH` or `VERIFY`. Each key is the original AWS mTLS header name (case-sensitive), and each value is the renamed header name. Supported keys are `X-Amzn-Mtls-Clientcert`, `X-Amzn-Mtls-Clientcert-Serial-Number`, `X-Amzn-Mtls-Clientcert-Issuer`, `X-Amzn-Mtls-Clientcert-Subject`, `X-Amzn-Mtls-Clientcert-Validity`, and `X-Amzn-Mtls-Clientcert-Leaf`. Headers not specified keep their default name.
  EOF
  type        = map(string)
  default     = {}
  nullable    = false

  validation {
    condition = alltrue([
      for key in keys(var.rename_mtls_request_headers) :
      contains(
        [
          "X-Amzn-Mtls-Clientcert",
          "X-Amzn-Mtls-Clientcert-Serial-Number",
          "X-Amzn-Mtls-Clientcert-Issuer",
          "X-Amzn-Mtls-Clientcert-Subject",
          "X-Amzn-Mtls-Clientcert-Validity",
          "X-Amzn-Mtls-Clientcert-Leaf",
        ],
        key
      )
    ])
    error_message = "Valid keys for `rename_mtls_request_headers` are `X-Amzn-Mtls-Clientcert`, `X-Amzn-Mtls-Clientcert-Serial-Number`, `X-Amzn-Mtls-Clientcert-Issuer`, `X-Amzn-Mtls-Clientcert-Subject`, `X-Amzn-Mtls-Clientcert-Validity`, and `X-Amzn-Mtls-Clientcert-Leaf`."
  }
  validation {
    condition = anytrue([
      length(var.rename_mtls_request_headers) == 0,
      var.protocol == "HTTPS",
    ])
    error_message = "`rename_mtls_request_headers` is only valid when `protocol` is `HTTPS`."
  }
}

variable "rename_tls_request_headers" {
  description = <<EOF
  (Optional) A map to rename the TLS context request headers that the load balancer forwards to targets. Only valid when `protocol` is `HTTPS`. Each key is the original AWS TLS header name (case-sensitive), and each value is the renamed header name. Supported keys are `X-Amzn-Tls-Version` and `X-Amzn-Tls-Cipher-Suite`. Headers not specified keep their default name.
  EOF
  type        = map(string)
  default     = {}
  nullable    = false

  validation {
    condition = alltrue([
      for key in keys(var.rename_tls_request_headers) :
      contains(
        [
          "X-Amzn-Tls-Version",
          "X-Amzn-Tls-Cipher-Suite",
        ],
        key
      )
    ])
    error_message = "Valid keys for `rename_tls_request_headers` are `X-Amzn-Tls-Version` and `X-Amzn-Tls-Cipher-Suite`."
  }
  validation {
    condition = anytrue([
      length(var.rename_tls_request_headers) == 0,
      var.protocol == "HTTPS",
    ])
    error_message = "`rename_tls_request_headers` is only valid when `protocol` is `HTTPS`."
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
