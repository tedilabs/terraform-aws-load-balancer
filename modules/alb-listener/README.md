# alb-listener

This module creates following resources.

- `aws_lb_listener`
- `aws_lb_listener_certificate` (optional)
- `aws_lb_listener_rule` (optional)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.71 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb_listener.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate) | resource |
| [aws_resourcegroups_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/resourcegroups_group) | resource |
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb_target_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_action_type"></a> [default\_action\_type](#input\_default\_action\_type) | (Required) The type of default routing action. Default action apply to traffic that does not meet the conditions of rules on your listener. Rules can be configured after the listener is created. Valid values are `FORWARD`, `WEIGHTED_FORWARD`, `FIXED_RESPONSE`, `REDIRECT_301` and `REDIRECT_302`. | `string` | n/a | yes |
| <a name="input_load_balancer"></a> [load\_balancer](#input\_load\_balancer) | (Required) The ARN of the application load balancer to add the listener. | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | (Required) The number of port on which the listener of load balancer is listening. | `number` | n/a | yes |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | (Required) The protocol for connections from clients to the load balancer. Valid values are `HTTP` and `HTTPS`. | `string` | n/a | yes |
| <a name="input_default_action_parameters"></a> [default\_action\_parameters](#input\_default\_action\_parameters) | (Optional) Configuration block for the parameters of the default routing action. `default_action_parameters` block as defined below.<br>    (Optional) `status_code` - The status code of HTTP response. Valid values are `2XX`, `4XX`, or `5XX`. Defaults to `503`. Only supported if `default_action_type` is `FIXED_RESPONSE`.<br>    (Optional) `content_type` - The value of `Content-Type` HTTP response header. Valid values are `text/plain`, `text/css`, `text/html`, `application/javascript` and `application/json`. Defaults to `text/plain`. Only supported if `default_action_type` is `FIXED_RESPONSE`.<br>    (Optional) `data` - The data of HTTP response body. Only supported if `default_action_type` is `FIXED_RESPONSE`.<br>    (Optional) `protocol` - The protocol of the redirect url. Valid values are `HTTP`, `HTTPS`, or `#{protocol}`. Defaults to `#{protocol}`. Only supported if `default_action_type` is `REDIRECT_301` or `REDIRECT_302`.<br>    (Optional) `host` - The hostname of the redirect url. This component is not percent-encoded. The hostname can contain `#{host}`. Defaults to `#{host}`. Only supported if `default_action_type` is `REDIRECT_301` or `REDIRECT_302`.<br>    (Optional) `port` - The port of the redirect url. Valid values are from `1` to `65535` or `#{port}`. Defaults to `#{port}`. Only supported if `default_action_type` is `REDIRECT_301` or `REDIRECT_302`.<br>    (Optional) `path` - The absolute path of the redirect url, starting with the leading `/`. This component is not percent-encoded. The path can contain `#{host}`, `#{path}`, and `#{port}`. Defaults to `/#{path}`. Only supported if `default_action_type` is `REDIRECT_301` or `REDIRECT_302`.<br>    (Optional) `query` - The query parameters of the redirect url, URL-encoded when necessary, but not percent-encoded. Do not include the leading `?`. Defaults to `#{query}`. Only supported if `default_action_type` is `REDIRECT_301` or `REDIRECT_302`.<br>    (Required) `target_group` - The ARN of the target group to which to route traffic. Use to route to a single target group. To route to one or more target groups, use `default_action_type` as `WEIGHTED_FORWARD`. Only supported if `default_action_type` is `FORWARD`.<br>    (Required) `targets` - A list of target configurations to route traffic. Each item of `targets` block as defined below. To route to a single target group, use `default_action_type` as `FORWARD`. Only supported if `default_action_type` is `WEIGHTED_FORWARD`.<br>      (Required) `target_group` - The ARN of the target group to which to route traffic.<br>      (Optional) `weight` - The weight to use routing traffic to `target_group`. Valid value is `0` to `999`. Defaults to `1`.<br>    (Optional) `stickiness_duration` - The duration of the session, in seconds, during which requests from a client should be routed to the same target group. Individual target stickiness is a configuration of the target group. Valid values are from `0` to `604800` (7 days). Specify `0` if you want to disable the stickiness. Defaults to `0`. Only supported if `default_action_type` is `WEIGHTED_FORWARD`. | `any` | `{}` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_resource_group_description"></a> [resource\_group\_description](#input\_resource\_group\_description) | (Optional) The description of Resource Group. | `string` | `"Managed by Terraform."` | no |
| <a name="input_resource_group_enabled"></a> [resource\_group\_enabled](#input\_resource\_group\_enabled) | (Optional) Whether to create Resource Group to find and group AWS resources which are created by this module. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_tls_additional_certificates"></a> [tls\_additional\_certificates](#input\_tls\_additional\_certificates) | (Optional) A set of ARNs of the certificate to attach to the listener. This is for additional certificates and does not replace the default certificate on the listener. | `set(string)` | `[]` | no |
| <a name="input_tls_certificate"></a> [tls\_certificate](#input\_tls\_certificate) | (Optional) The ARN of the default SSL server certificate. For adding additional SSL certificates, see the `tls_additional_certificates` variable. Required if `protocol` is `HTTPS`. | `string` | `null` | no |
| <a name="input_tls_security_policy"></a> [tls\_security\_policy](#input\_tls\_security\_policy) | (Optional) The name of security policy for a Secure Socket Layer (SSL) negotiation configuration. This is used to negotiate SSL connections with clients. Required if protocol is `HTTPS`. Defaults to `ELBSecurityPolicy-2016-08` security policy. The `ELBSecurityPolicy-2016-08` security policy is always used for backend connections. Application Load Balancers do not support custom security policies. | `string` | `"ELBSecurityPolicy-2016-08"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the listener. |
| <a name="output_default_action"></a> [default\_action](#output\_default\_action) | The default action for traffic on this listener. Default action apply to traffic that does not meet the conditions of rules on your listener. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the listener. |
| <a name="output_name"></a> [name](#output\_name) | The name of the listener. |
| <a name="output_port"></a> [port](#output\_port) | The port number on which the listener of load balancer is listening. |
| <a name="output_protocol"></a> [protocol](#output\_protocol) | The protocol for connections of the listener. |
| <a name="output_tls"></a> [tls](#output\_tls) | TLS configurations of the listener. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
