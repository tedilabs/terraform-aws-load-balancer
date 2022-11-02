# gwlb-instance-target-group

This module creates following resources.

- `aws_lb_target_group`
- `aws_lb_target_group_attachment` (optional)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.71 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.36.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.10.0 |

## Resources

| Name | Type |
|------|------|
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | (Required) Name of the target group. A maximum of 32 alphanumeric characters including hyphens are allowed, but the name must not begin or end with a hyphen. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Required) The ID of the VPC which the target group belongs to. | `string` | n/a | yes |
| <a name="input_deregistration_delay"></a> [deregistration\_delay](#input\_deregistration\_delay) | (Optional) The time to wait for in-flight requests to complete while deregistering a target. During this time, the state of the target is draining. | `number` | `300` | no |
| <a name="input_health_check"></a> [health\_check](#input\_health\_check) | (Optional) Health Check configuration block. The associated load balancer periodically sends requests to the registered targets to test their status. `health_check` block as defined below.<br>    (Optional) `protocol` - Protocol to use to connect with the target. The possible values are `TCP`, `HTTP` and `HTTPS`. Defaults to `TCP`.<br>    (Optional) `port` - The port the load balancer uses when performing health checks on targets. The default is `80`. Valid values are either ports 1-65535.<br>    (Optional) `port_override` - Whether to override the port on which each target receives trafficfrom the load balancer to a different port. Defaults to `true`.<br>    (Optional) `path` - Use the default path of `/` to ping the root, or specify a custom path if preferred. Only valid if the `protocol` is `HTTP` or `HTTPS`.<br>    (Optional) `healthy_threshold` - The number of consecutive health checks successes required before considering an unhealthy target healthy. Valid value range is 2 - 10. Defaults to `3`.<br>    (Optional) `unhealthy_threshold` - The number of consecutive health check failures required before considering a target unhealthy. Valid value range is 2 - 10. Defaults to `3`.<br>    (Optional) `interval` - Approximate amount of time, in seconds, between health checks of an individual target. Valid value range is 5 - 300. Defaults to `10`.<br>    (Optional) `timeout` - The amount of time, in seconds, during which no response means a failed health check. Valid value range is 2 - 120. Defaults to `5`. | <pre>object({<br>    protocol      = optional(string, "TCP")<br>    port          = optional(number, 80)<br>    port_override = optional(bool, true)<br>    path          = optional(string, "/")<br><br>    healthy_threshold   = optional(number, 3)<br>    unhealthy_threshold = optional(number, 3)<br>    interval            = optional(number, 10)<br>    timeout             = optional(number, 5)<br>  })</pre> | `{}` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_resource_group_description"></a> [resource\_group\_description](#input\_resource\_group\_description) | (Optional) The description of Resource Group. | `string` | `"Managed by Terraform."` | no |
| <a name="input_resource_group_enabled"></a> [resource\_group\_enabled](#input\_resource\_group\_enabled) | (Optional) Whether to create Resource Group to find and group AWS resources which are created by this module. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_targets"></a> [targets](#input\_targets) | (Optional) A set of targets to add to the target group. Each value of `targets` block as defined below.<br>    (Required) `instance` - This is the Instance ID for an instance, or the container ID for an ECS container. | <pre>set(object({<br>    instance = string<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the target group. |
| <a name="output_arn_suffix"></a> [arn\_suffix](#output\_arn\_suffix) | The ARN suffix for use with CloudWatch Metrics. |
| <a name="output_attributes"></a> [attributes](#output\_attributes) | Attributes of the Instance target group of gateway load balancer. |
| <a name="output_health_check"></a> [health\_check](#output\_health\_check) | Health Check configuration of the target group. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the target group. |
| <a name="output_name"></a> [name](#output\_name) | The name of the target group. |
| <a name="output_port"></a> [port](#output\_port) | The port number on which the target receive trrafic. |
| <a name="output_protocol"></a> [protocol](#output\_protocol) | The protocol to use to connect with the target. |
| <a name="output_targets"></a> [targets](#output\_targets) | A set of targets in the target group. |
| <a name="output_type"></a> [type](#output\_type) | The target type of the target group. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC which the target group belongs to. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
