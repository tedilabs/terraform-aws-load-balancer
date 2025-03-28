# alb-lambda-target-group

This module creates following resources.

- `aws_lb_target_group`
- `aws_lb_target_group_attachment` (optional)
- `aws_lambda_permission` (optional)

<!-- BEGIN_TF_DOCS -->
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
| [aws_lambda_permission.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | (Required) Name of the target group. | `string` | n/a | yes |
| <a name="input_health_check"></a> [health\_check](#input\_health\_check) | (Optional) Health Check configuration block. The associated load balancer periodically sends requests to the registered targets to test their status. `health_check` block as defined below.<br>    (Optional) `enabled` - Whether health checks are enabled. Health checks count as a request for your Lambda function. Defaults to `false`.<br>    (Optional) `path` - Use the default path of `/` to ping the root, or specify a custom path if preferred.<br>    (Optional) `success_codes` - The HTTP codes to use when checking for a successful response from a target. You can specify multiple values (for example, `200,202`) or a range of values (for example, `200-299`). Defaults to `200`.<br>    (Optional) `healthy_threshold` - The number of consecutive health checks successes required before considering an unhealthy target healthy. Valid value range is 2 - 10. Defaults to `5`.<br>    (Optional) `unhealthy_threshold` - The number of consecutive health check failures required before considering a target unhealthy. Valid value range is 2 - 10. Defaults to `2`.<br>    (Optional) `interval` - Approximate amount of time, in seconds, between health checks of an individual target. Valid value range is 5 - 300. Defaults to `35`.<br>    (Optional) `timeout` - The amount of time, in seconds, during which no response means a failed health check. Valid value range is 2 - 120. Defaults to `30`. | <pre>object({<br>    enabled       = optional(bool, false)<br>    path          = optional(string, "/")<br>    success_codes = optional(string, "200")<br><br>    healthy_threshold   = optional(number, 5)<br>    unhealthy_threshold = optional(number, 2)<br>    interval            = optional(number, 35)<br>    timeout             = optional(number, 30)<br>  })</pre> | `{}` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_multi_value_headers_enabled"></a> [multi\_value\_headers\_enabled](#input\_multi\_value\_headers\_enabled) | (Optional) Indicates whether the request and response headers that are exchanged between the load balancer and the Lambda function include arrays of values or strings. Defaults to `false`. If the value is false and the request contains a duplicate header field name or query parameter key, the load balancer uses the last value sent by the client. | `bool` | `false` | no |
| <a name="input_resource_group_description"></a> [resource\_group\_description](#input\_resource\_group\_description) | (Optional) The description of Resource Group. | `string` | `"Managed by Terraform."` | no |
| <a name="input_resource_group_enabled"></a> [resource\_group\_enabled](#input\_resource\_group\_enabled) | (Optional) Whether to create Resource Group to find and group AWS resources which are created by this module. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_targets"></a> [targets](#input\_targets) | (Optional) A list of targets to add to the target group. The Lambda target group is limited to a single Lambda function target. The load balancer starts routing requests to a newly registered target as soon as the registration process completes and the target passes the initial health checks (if enabled). Each value of `targets` block as defined below.<br>    (Required) `lambda_function` - The Amazon Resource Name (ARN) of the target Lambda. If your ARN does not specify a version or alias, the latest version ($LATEST) will be used by default. ARNs that specify a version / alias do so after the function name, and are separated by a colon. | <pre>set(object({<br>    lambda_function = string<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the target group. |
| <a name="output_arn_suffix"></a> [arn\_suffix](#output\_arn\_suffix) | The ARN suffix for use with CloudWatch Metrics. |
| <a name="output_attributes"></a> [attributes](#output\_attributes) | Attributes of the Lambda target group of application load balancer. |
| <a name="output_health_check"></a> [health\_check](#output\_health\_check) | Health Check configuration of the target group. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the target group. |
| <a name="output_load_balancers"></a> [load\_balancers](#output\_load\_balancers) | The ARNs (Amazon Resource Name) of the load balancers associated with the target group. |
| <a name="output_name"></a> [name](#output\_name) | The name of the target group. |
| <a name="output_targets"></a> [targets](#output\_targets) | A list of targets in the target group. The Lambda target group is limited to a single Lambda function target. |
| <a name="output_type"></a> [type](#output\_type) | The target type of the target group. |
<!-- END_TF_DOCS -->
