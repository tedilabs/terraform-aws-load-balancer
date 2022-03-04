# alb-instance-target-group

This module creates following resources.

- `aws_lb_target_group`
- `aws_lb_target_group_attachment` (optional)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.71 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_resourcegroups_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/resourcegroups_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | (Required) Name of the target group. A maximum of 32 alphanumeric characters including hyphens are allowed, but the name must not begin or end with a hyphen. | `string` | n/a | yes |
| <a name="input_port"></a> [port](#input\_port) | (Required) The number of port on which targets receive traffic, unless overridden when registering a specific target. Valid values are either ports 1-65535. | `number` | n/a | yes |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | (Required) The protocol to use for routing traffic to the targets. Valid values are `HTTP` and `HTTPS`. Defaults to `HTTP`. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Required) The ID of the VPC which the target group belongs to. | `string` | n/a | yes |
| <a name="input_deregistration_delay"></a> [deregistration\_delay](#input\_deregistration\_delay) | (Optional) The time to wait for in-flight requests to complete while deregistering a target. During this time, the state of the target is draining. | `number` | `300` | no |
| <a name="input_health_check"></a> [health\_check](#input\_health\_check) | (Optional) Health Check configuration block. The associated load balancer periodically sends requests to the registered targets to test their status. `health_check` block as defined below.<br>    (Optional) `port` - The port the load balancer uses when performing health checks on targets. The default is the port on which each target receives traffic from the load balancer. Valid values are either ports 1-65535.<br>    (Optional) `protocol` - Protocol to use to connect with the target. The possible values are `HTTP` and `HTTPS`. Defaults to `HTTP`.<br>    (Optional) `healthy_threshold` - The number of consecutive health checks successes required before considering an unhealthy target healthy. Valid value range is 2 - 10. Defaults to `5`.<br>    (Optional) `unhealthy_threshold` - The number of consecutive health check failures required before considering a target unhealthy. Valid value range is 2 - 10. Defaults to `2`.<br>    (Optional) `interval` - Approximate amount of time, in seconds, between health checks of an individual target. Valid value range is 5 - 300. Defaults to `30`.<br>    (Optional) `timeout` - The amount of time, in seconds, during which no response means a failed health check. Valid value range is 2 - 120. Defaults to `5`.<br>    (Optional) `success_codes` - The HTTP codes to use when checking for a successful response from a target. You can specify multiple values (for example, `200,202`) or a range of values (for example, `200-299`).<br>    (Optional) `path` - Use the default path of `/` to ping the root, or specify a custom path if preferred. | `any` | `{}` | no |
| <a name="input_load_balancing_algorithm"></a> [load\_balancing\_algorithm](#input\_load\_balancing\_algorithm) | (Optional) Determines how the load balancer selects targets when routing requests. Valid values are `ROUND_ROBIN` or `LEAST_OUTSTANDING_REQUESTS`. Defaults to `ROUND_ROBIN`. | `string` | `"ROUND_ROBIN"` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_protocol_version"></a> [protocol\_version](#input\_protocol\_version) | (Optional) Use `HTTP1` to send requests to targets using HTTP/1.1. Supported when the request protocol is HTTP/1.1 or HTTP/2. Use `HTTP2` to send requests to targets using HTTP/2. Supported when the request protocol is HTTP/2 or gRPC, but gRPC-specific features are not available. Use `GRPC` to send requests to targets using gRPC. Supported when the request protocol is gRPC. Defaults to `HTTP1`. | `string` | `"HTTP1"` | no |
| <a name="input_resource_group_description"></a> [resource\_group\_description](#input\_resource\_group\_description) | (Optional) The description of Resource Group. | `string` | `"Managed by Terraform."` | no |
| <a name="input_resource_group_enabled"></a> [resource\_group\_enabled](#input\_resource\_group\_enabled) | (Optional) Whether to create Resource Group to find and group AWS resources which are created by this module. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. | `string` | `""` | no |
| <a name="input_slow_start_duration"></a> [slow\_start\_duration](#input\_slow\_start\_duration) | (Optional) The amount time for a newly registered targets to warm up before the load balancer sends them a full share of requests. During this period, targets receives an increasing share of requests until it reaches its fair share. Requires `30` to `900` seconds to enable, or `0` seconds to disable. This attribute cannot be combined with the Least outstanding requests algorithm. | `number` | `0` | no |
| <a name="input_stickiness_cookie"></a> [stickiness\_cookie](#input\_stickiness\_cookie) | (Optional) The name of the application based cookie. `AWSALB`, `AWSALBAPP`, and `AWSALBTG` prefixes are reserved and cannot be used. Only needed when `stickiness_type` is `APP_COOKIE`. | `string` | `null` | no |
| <a name="input_stickiness_duration"></a> [stickiness\_duration](#input\_stickiness\_duration) | (Optional) The time period, in seconds, during which requests from a client should be routed to the same target. After this time period expires, the load balancer-generated cookie is considered stale. Valid values are from `1` to `604800` (1 week). Defaults to `86400` (1 day). | `number` | `86400` | no |
| <a name="input_stickiness_enabled"></a> [stickiness\_enabled](#input\_stickiness\_enabled) | (Optional) Whether to enable the type of stickiness associated with this target group. If enabled, the load balancer binds a client’s session to a specific instance within the target group. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_stickiness_type"></a> [stickiness\_type](#input\_stickiness\_type) | (Optional) The type of sticky sessions. Valid values are `LB_COOKIE` or `APP_COOKIE`. Defaults to `LB_COOKIE`. | `string` | `"LB_COOKIE"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_targets"></a> [targets](#input\_targets) | (Optional) A set of targets to add to the target group. Each value of `targets` block as defined below.<br>    (Required) `instance` - This is the Instance ID for an instance, or the container ID for an ECS container.<br>    (Optional) `port` - The port on which targets receive traffic. | `set(map(string))` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the target group. |
| <a name="output_arn_suffix"></a> [arn\_suffix](#output\_arn\_suffix) | The ARN suffix for use with CloudWatch Metrics. |
| <a name="output_attributes"></a> [attributes](#output\_attributes) | Attributes of the Instance target group of network load balancer. |
| <a name="output_health_check"></a> [health\_check](#output\_health\_check) | Health Check configuration of the target group. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the target group. |
| <a name="output_name"></a> [name](#output\_name) | The name of the target group. |
| <a name="output_port"></a> [port](#output\_port) | The port number on which the target receive trrafic. |
| <a name="output_protocol"></a> [protocol](#output\_protocol) | The protocol to use to connect with the target. |
| <a name="output_protocol_version"></a> [protocol\_version](#output\_protocol\_version) | The protocol version to use to send requests to targets. |
| <a name="output_targets"></a> [targets](#output\_targets) | A set of targets in the target group. |
| <a name="output_type"></a> [type](#output\_type) | The target type of the target group. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC which the target group belongs to. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
