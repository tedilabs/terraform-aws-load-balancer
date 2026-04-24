# gwlb-instance-target-group

This module creates following resources.

- `aws_lb_target_group`
- `aws_lb_target_group_attachment` (optional)

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
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | (Required) Name of the target group. A maximum of 32 alphanumeric characters including hyphens are allowed, but the name must not begin or end with a hyphen. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Required) The ID of the VPC which the target group belongs to. | `string` | n/a | yes |
| <a name="input_deregistration_delay"></a> [deregistration\_delay](#input\_deregistration\_delay) | (Optional) The time to wait for in-flight requests to complete while deregistering a target. During this time, the state of the target is draining. Valid values are from `0` to `3600` seconds. Defaults to `300` seconds. | `number` | `300` | no |
| <a name="input_flow_stickiness"></a> [flow\_stickiness](#input\_flow\_stickiness) | (Optional) A configuration for flow stickiness of the target group. `flow_stickiness` as defined below.<br/>    (Optional) `type` - The type of flow stickiness. Valid values are `5-tuple`, `3-tuple` and `2-tuple`. Defaults to `5-tuple`.<br/>      `5-tuple` - Source IP, Source Port, Destination IP, Destination Port and Transport Protocol.<br/>      `3-tuple` - Source IP, Destination IP and Transport Protocol.<br/>      `2-tuple` - Source IP and Destination IP. | <pre>object({<br/>    type = optional(string, "5-tuple")<br/>  })</pre> | `{}` | no |
| <a name="input_health_check"></a> [health\_check](#input\_health\_check) | (Optional) A configurations for Health Check of the target group. The associated load balancer periodically sends requests to the registered targets to test their status. `health_check` block as defined below.<br/>    (Optional) `protocol` - Protocol to use to connect with the target. The possible values are `TCP`, `HTTP` and `HTTPS`. Defaults to `TCP`.<br/>    (Optional) `port` - The port the load balancer uses when performing health checks on targets. The default is the port on which each target receives traffic from the load balancer. Valid values are either ports 1-65535.<br/>    (Optional) `port_override` - Whether to override the port on which each target receives traffic from the load balancer to a different port. Defaults to `false`.<br/>    (Optional) `path` - The ping path for the HTTP or HTTPS protocol. Defaults to `/`. A path can have a maximum of 1024 characters.<br/>    (Optional) `success_codes` - The HTTP codes to use when checking for a successful response from a target for the HTTP or HTPS protocol. You can specify multiple values (for example, `200,202`) or a range of values (for example, `200-299`). Defaults to `200-399`.<br/>    (Optional) `healthy_threshold` - The number of consecutive health checks successes required before considering an unhealthy target healthy. Valid value range is 2 - 10. Defaults to `5`.<br/>    (Optional) `unhealthy_threshold` - The number of consecutive health check failures required before considering a target unhealthy. Valid value range is 2 - 10. Defaults to `2`.<br/>    (Optional) `interval` - Approximate amount of time, in seconds, between health checks of an individual target. Valid value range is 5 - 300. Defaults to `30`.<br/>    (Optional) `timeout` - The amount of time, in seconds, during which no response means a failed health check. Valid value range is 2 - 120. Defaults to `5`. | <pre>object({<br/>    protocol      = optional(string, "TCP")<br/>    port          = optional(number)<br/>    port_override = optional(bool, false)<br/>    path          = optional(string, "/")<br/>    success_codes = optional(string, "200-399")<br/><br/>    healthy_threshold   = optional(number, 5)<br/>    unhealthy_threshold = optional(number, 2)<br/>    interval            = optional(number, 10)<br/>    timeout             = optional(number, 5)<br/>  })</pre> | `{}` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_target_failover"></a> [target\_failover](#input\_target\_failover) | (Optional) A configuration for how Gateway Load Balancer handles existing flows on target deregistration and unhealthy events. `target_failover` as defined below.<br/>    (Optional) `rebalance_on_deregistration` - Whether to rebalance existing flows when a target is deregistered. If `true`, the load balancer will rebalance existing flows across the remaining healthy targets. Defaults to `false`.<br/>    (Optional) `rebalance_on_unhealthy` - Whether to rebalance existing flows when a target is marked unhealthy. If `true`, the load balancer will rebalance existing flows across the remaining healthy targets. Defaults to `false`. | <pre>object({<br/>    rebalance_on_deregistration = optional(bool, false)<br/>    rebalance_on_unhealthy      = optional(bool, false)<br/>  })</pre> | `{}` | no |
| <a name="input_targets"></a> [targets](#input\_targets) | (Optional) A set of targets to add to the target group. Each value of `targets` block as defined below.<br/>    (Required) `instance` - This is the Instance ID for an instance, or the container ID for an ECS container. | <pre>set(object({<br/>    instance = string<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the target group. |
| <a name="output_arn_suffix"></a> [arn\_suffix](#output\_arn\_suffix) | The ARN suffix for use with CloudWatch Metrics. |
| <a name="output_attributes"></a> [attributes](#output\_attributes) | Attributes of the Instance target group of gateway load balancer. |
| <a name="output_flow_stickiness"></a> [flow\_stickiness](#output\_flow\_stickiness) | The configuration of flow stickiness for the target group. |
| <a name="output_health_check"></a> [health\_check](#output\_health\_check) | Health Check configuration of the target group. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the target group. |
| <a name="output_load_balancers"></a> [load\_balancers](#output\_load\_balancers) | The ARNs (Amazon Resource Name) of the load balancers associated with the target group. |
| <a name="output_name"></a> [name](#output\_name) | The name of the target group. |
| <a name="output_port"></a> [port](#output\_port) | The port number on which the target receive trrafic. |
| <a name="output_protocol"></a> [protocol](#output\_protocol) | The protocol to use to connect with the target. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
| <a name="output_target_failover"></a> [target\_failover](#output\_target\_failover) | The configuration of target failover for the target group. |
| <a name="output_targets"></a> [targets](#output\_targets) | A set of targets in the target group. |
| <a name="output_type"></a> [type](#output\_type) | The target type of the target group. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC which the target group belongs to. |
<!-- END_TF_DOCS -->
