# nlb-listener

This module creates following resources.

- `aws_lb_listener`
- `aws_lb_listener_certificate` (optional)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.42 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.42.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.12.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_lb_listener.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_default_action_type"></a> [default\_action\_type](#input\_default\_action\_type) | (Required) The type of default routing action. Valid values are `FORWARD`, `WEIGHTED_FORWARD`. | `string` | n/a | yes |
| <a name="input_load_balancer"></a> [load\_balancer](#input\_load\_balancer) | (Required) The ARN of the network load balancer to add the listener. | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | (Required) The number of port on which the listener of load balancer is listening. | `number` | n/a | yes |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | (Required) The protocol for connections from clients to the load balancer. Valid values are `TCP`, `TLS`, `UDP`, `TCP_UDP`, `QUIC` and `TCP_QUIC`. Not valid to use `UDP` or `TCP_UDP` if dual-stack mode is enabled on the load balancer. Not valid to use `QUIC` or `TCP_QUIC` if security groups are configured or dual-stack mode is enabled. | `string` | n/a | yes |
| <a name="input_default_action_parameters"></a> [default\_action\_parameters](#input\_default\_action\_parameters) | (Optional) Configuration block for the parameters of the default routing action. `default_action_parameters` block as defined below.<br/>    (Optional) `target_group` - The ARN of the target group to which to route traffic. Use to route to a single target group. To route to one or more target groups, use `default_action_type` as `WEIGHTED_FORWARD`. Only supported if `default_action_type` is `FORWARD`.<br/>    (Optional) `targets` - A list of target configurations to route traffic. To route to a single target group, use `default_action_type` as `FORWARD`. Only supported if `default_action_type` is `WEIGHTED_FORWARD`. Each item of `targets` block as defined below.<br/>      (Required) `target_group` - The ARN of the target group to which to route traffic.<br/>      (Optional) `weight` - The weight to use routing traffic to `target_group`. Valid value is `0` to `999`. Defaults to `1`.<br/>    (Optional) `stickiness_duration` - The duration of the session, in seconds, during which requests from a client should be routed to the same target group. Individual target stickiness is a configuration of the target group. Valid values are from `0` to `604800` (7 days). Specify `0` if you want to disable the stickiness. Defaults to `0`. Only supported if `default_action_type` is `WEIGHTED_FORWARD`. | <pre>object({<br/>    target_group = optional(string)<br/><br/>    targets = optional(list(object({<br/>      target_group = string<br/>      weight       = optional(number, 1)<br/>    })), [])<br/>    stickiness_duration = optional(number, 0)<br/>  })</pre> | `{}` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_tcp_idle_timeout"></a> [tcp\_idle\_timeout](#input\_tcp\_idle\_timeout) | (Optional) The number of seconds before the listener determines that the TCP connection is idle and closes it. Only applied when `protocol` is `TCP` or `TCP_UDP`. Valid values are `60` to `6000`. Defaults to `350`. | `number` | `350` | no |
| <a name="input_tls"></a> [tls](#input\_tls) | (Optional) The configuration for TLS listener of the load balancer. Required if `protocol` is `TLS`. `tls` block as defined below.<br/>    (Optional) `certificate` - The ARN of the default SSL server certificate. For adding additional SSL certificates, see the `additional_certificates` variable.<br/>    (Optional) `additional_certificates` - A set of ARNs of the certificate to attach to the listener. This is for additional certificates and does not replace the default certificate on the listener.<br/>    (Optional) `security_policy` - The name of security policy for a Secure Socket Layer (SSL) negotiation configuration. This is used to negotiate SSL connections with clients. Required if protocol is `TLS`. Recommend using the `ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09` security policy.<br/>    (Optional) `alpn_policy` - The policy of the Application-Layer Protocol Negotiation (ALPN) to select. ALPN is a TLS extension that includes the protocol negotiation within the exchange of hello messages. Can be set if `protocol` is `TLS`. Valid values are `HTTP1Only`, `HTTP2Only`, `HTTP2Optional`, `HTTP2Preferred`, and `None`. Defaults to `None`. | <pre>object({<br/>    certificate             = optional(string)<br/>    additional_certificates = optional(set(string), [])<br/>    security_policy         = optional(string, "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09")<br/>    alpn_policy             = optional(string, "None")<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the listener. |
| <a name="output_default_action"></a> [default\_action](#output\_default\_action) | The default action for traffic on this listener. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the listener. |
| <a name="output_name"></a> [name](#output\_name) | The name of the listener. |
| <a name="output_port"></a> [port](#output\_port) | The port number on which the listener of load balancer is listening. |
| <a name="output_protocol"></a> [protocol](#output\_protocol) | The protocol for connections of the listener. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
| <a name="output_tcp_idle_timeout"></a> [tcp\_idle\_timeout](#output\_tcp\_idle\_timeout) | The number of seconds before the listener determines that the TCP connection is idle and closes it. |
| <a name="output_tls"></a> [tls](#output\_tls) | TLS configurations of the listener. |
<!-- END_TF_DOCS -->
