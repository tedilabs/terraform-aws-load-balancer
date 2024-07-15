# nlb-ip-target-group

This module creates following resources.

- `aws_lb_target_group`
- `aws_lb_target_group_attachment` (optional)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.38 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.58.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.10.0 |

## Resources

| Name | Type |
|------|------|
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | (Required) Name of the target group. A maximum of 32 alphanumeric characters including hyphens are allowed, but the name must not begin or end with a hyphen. | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | (Required) The number of port on which targets receive traffic, unless overridden when registering a specific target. Valid values are either ports 1-65535. | `number` | n/a | yes |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | (Required) The protocol to use for routing traffic to the targets. Valid values are `TCP`, `TLS`, `UDP` and `TCP_UDP`. Not valid to use `UDP` or `TCP_UDP` if dual-stack mode is enabled on the load balancer. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Required) The ID of the VPC which the target group belongs to. | `string` | n/a | yes |
| <a name="input_deregistration_delay"></a> [deregistration\_delay](#input\_deregistration\_delay) | (Optional) The time to wait for in-flight requests to complete while deregistering a target. During this time, the state of the target is draining. | `number` | `300` | no |
| <a name="input_health_check"></a> [health\_check](#input\_health\_check) | (Optional) Health Check configuration block. The associated load balancer periodically sends requests to the registered targets to test their status. `health_check` block as defined below.<br>    (Optional) `protocol` - Protocol to use to connect with the target. The possible values are `TCP`, `HTTP` and `HTTPS`. Defaults to `TCP`.<br>    (Optional) `port` - The port the load balancer uses when performing health checks on targets. The default is the port on which each target receives traffic from the load balancer. Valid values are either ports 1-65535.<br>    (Optional) `port_override` - Whether to override the port on which each target receives trafficfrom the load balancer to a different port. Defaults to `false`.<br>    (Optional) `path` - Use the default path of `/` to ping the root, or specify a custom path if preferred. Only valid if the `protocol` is `HTTP` or `HTTPS`.<br>    (Optional) `healthy_threshold` - The number of consecutive health checks successes required before considering an unhealthy target healthy. Valid value range is 2 - 10. Defaults to `3`.<br>    (Optional) `unhealthy_threshold` - The number of consecutive health check failures required before considering a target unhealthy. Valid value range is 2 - 10. Defaults to `3`.<br>    (Optional) `interval` - Approximate amount of time, in seconds, between health checks of an individual target. Valid value range is 5 - 300. Defaults to `10`. | <pre>object({<br>    protocol      = optional(string, "TCP")<br>    port          = optional(number, null)<br>    port_override = optional(bool, false)<br>    path          = optional(string, "/")<br><br>    healthy_threshold   = optional(number, 3)<br>    unhealthy_threshold = optional(number, 3)<br>    interval            = optional(number, 10)<br>  })</pre> | `{}` | no |
| <a name="input_ip_address_type"></a> [ip\_address\_type](#input\_ip\_address\_type) | (Required) The type of IP addresses used by the target group. Valid values are `IPV4` or `IPV6`. | `string` | `"IPV4"` | no |
| <a name="input_load_balancing"></a> [load\_balancing](#input\_load\_balancing) | (Optional) A load balancing configuration of the target group. `load_balancing` block as defined below.<br>    (Optional) `cross_zone_strategy` - Determines how the load balancer routes requests across the Availability Zones. Valid values are `ENABLED`, `DISABLED` or `INHERIT`. Defaults to `INHERIT` (Use load balancer configuration). | <pre>object({<br>    cross_zone_strategy = optional(string, "INHERIT")<br>  })</pre> | `{}` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_preserve_client_ip"></a> [preserve\_client\_ip](#input\_preserve\_client\_ip) | (Optional) Whether to preserve client IP addresses and ports in the packets forwarded to targets. Client IP preservation cannot be disabled if the target group protocol is `UDP` and `TCP_UDP`. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_proxy_protocol_v2"></a> [proxy\_protocol\_v2](#input\_proxy\_protocol\_v2) | (Optional) Whether to enable support for proxy protocol v2 on Network Load Balancers. Before you enable proxy protocol v2, make sure that your application targets can process proxy protocol headers otherwise your application might break. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_resource_group_description"></a> [resource\_group\_description](#input\_resource\_group\_description) | (Optional) The description of Resource Group. | `string` | `"Managed by Terraform."` | no |
| <a name="input_resource_group_enabled"></a> [resource\_group\_enabled](#input\_resource\_group\_enabled) | (Optional) Whether to create Resource Group to find and group AWS resources which are created by this module. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. | `string` | `""` | no |
| <a name="input_stickiness_enabled"></a> [stickiness\_enabled](#input\_stickiness\_enabled) | (Optional) Whether to enable the type of stickiness associated with this target group. If enabled, the load balancer binds a client’s session to a specific instance within the target group. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_targets"></a> [targets](#input\_targets) | (Optional) A set of targets to add to the target group. Each value of `targets` block as defined below.<br>    (Required) `ip_address` - Specify IP addresses from the subnets of the virtual private cloud (VPC) for the target group, the RFC 1918 range (10.0.0.0/8, 172.16.0.0/12, and 192.168.0.0/16), and the RFC 6598 range (100.64.0.0/10). You can't specify publicly routable IP addresses. Support also IPv6 addresses.<br>    (Optional) `port` - The port on which targets receive traffic. | <pre>set(object({<br>    ip_address = string<br>    port       = optional(number, null)<br>  }))</pre> | `[]` | no |
| <a name="input_terminate_connection_on_deregistration"></a> [terminate\_connection\_on\_deregistration](#input\_terminate\_connection\_on\_deregistration) | (Optional) Whether to terminate active connections at the end of the deregistration timeout is reached on Network Load Balancers. Enabling this setting is particularly important for `UDP` and `TCP_UDP` target groups. Defaults to `false`. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the target group. |
| <a name="output_arn_suffix"></a> [arn\_suffix](#output\_arn\_suffix) | The ARN suffix for use with CloudWatch Metrics. |
| <a name="output_attributes"></a> [attributes](#output\_attributes) | Attributes of the Instance target group of network load balancer. |
| <a name="output_health_check"></a> [health\_check](#output\_health\_check) | Health Check configuration of the target group. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the target group. |
| <a name="output_ip_address_type"></a> [ip\_address\_type](#output\_ip\_address\_type) | The type of IP addresses used by the target group. |
| <a name="output_load_balancers"></a> [load\_balancers](#output\_load\_balancers) | The ARNs (Amazon Resource Name) of the load balancers associated with the target group. |
| <a name="output_name"></a> [name](#output\_name) | The name of the target group. |
| <a name="output_port"></a> [port](#output\_port) | The port number on which the target receive trrafic. |
| <a name="output_protocol"></a> [protocol](#output\_protocol) | The protocol to use to connect with the target. |
| <a name="output_targets"></a> [targets](#output\_targets) | A set of targets in the target group. |
| <a name="output_type"></a> [type](#output\_type) | The target type of the target group. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC which the target group belongs to. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
