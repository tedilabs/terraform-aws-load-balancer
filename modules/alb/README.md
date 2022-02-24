# alb

This module creates following resources.

- `aws_lb`
- `aws_lb_listener` (optional)
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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_listener"></a> [listener](#module\_listener) | ../alb-listener | n/a |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | tedilabs/network/aws//modules/security-group | ~> 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_resourcegroups_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/resourcegroups_group) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the load balancer. This name must be unique within your AWS account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Required) The ID of the VPC which the load balancer belongs to. | `string` | n/a | yes |
| <a name="input_access_log_enabled"></a> [access\_log\_enabled](#input\_access\_log\_enabled) | (Optional) Indicates whether to enable access logs. Defaults to `false`, even when bucket is specified. | `bool` | `false` | no |
| <a name="input_access_log_s3_bucket"></a> [access\_log\_s3\_bucket](#input\_access\_log\_s3\_bucket) | (Optional) The name of the S3 bucket used to store the access logs. | `string` | `null` | no |
| <a name="input_access_log_s3_key_prefix"></a> [access\_log\_s3\_key\_prefix](#input\_access\_log\_s3\_key\_prefix) | (Optional) The key prefix for the specified S3 bucket. | `string` | `null` | no |
| <a name="input_default_security_group"></a> [default\_security\_group](#input\_default\_security\_group) | (Optional) The configuration of the default security group for your load balancer. `default_security_group` block as defined below.<br>    (Optional) `name` - The name of the default security group.<br>    (Optional) `description` - The description of the default security group.<br>    (Optional) `ingress_cidrs` - A list of IPv4 CIDR blocks to allow inbound traffic from.<br>    (Optional) `ingress_ipv6_cidrs` - A list of IPv6 CIDR blocks to allow inbound traffic from.<br>    (Optional) `ingress_prefix_lists` - A list of Prefix List IDs to allow inbound traffic from.<br>    (Optional) `ingress_security_groups` - A list of source Security Group IDs to allow inbound traffic from. | `any` | `{}` | no |
| <a name="input_deletion_protection_enabled"></a> [deletion\_protection\_enabled](#input\_deletion\_protection\_enabled) | (Optional) Indicates whether deletion of the load balancer via the AWS API will be protected. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_desync_mitigation_mode"></a> [desync\_mitigation\_mode](#input\_desync\_mitigation\_mode) | (Optional) Determines how the load balancer handles requests that might pose a security risk to your application. Valid values are `DEFENSIVE`, `STRICTEST` and `MONITOR`. Defaults to `DEFENSIVE`. | `string` | `"DEFENSIVE"` | no |
| <a name="input_drop_invalid_header_fields"></a> [drop\_invalid\_header\_fields](#input\_drop\_invalid\_header\_fields) | (Optional) Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false). Elastic Load Balancing requires that message header names contain only alphanumeric characters and hyphens. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_http2_enabled"></a> [http2\_enabled](#input\_http2\_enabled) | (Optional) Indicates whether HTTP/2 is enabled. Defaults to `true`. | `bool` | `true` | no |
| <a name="input_idle_timeout"></a> [idle\_timeout](#input\_idle\_timeout) | (Optional) The number of seconds before the load balancer determines the connection is idle and closes it. Defaults to `60` | `number` | `60` | no |
| <a name="input_ip_address_type"></a> [ip\_address\_type](#input\_ip\_address\_type) | (Optional) The type of IP addresses used by the subnets for your load balancer. The possible values are `IPV4` and `DUALSTACK`. | `string` | `"IPV4"` | no |
| <a name="input_is_public"></a> [is\_public](#input\_is\_public) | (Optional) Indicates whether the load balancer will be public. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_listeners"></a> [listeners](#input\_listeners) | (Optional) A list of listener configurations of the application load balancer. Listeners listen for connection requests using their `protocol` and `port`. Each value of `listener` block as defined below.<br>    (Required) `port` - The number of port on which the listener of load balancer is listening.<br>    (Required) `protocol` - The protocol for connections from clients to the load balancer. Valid values are `HTTP` and `HTTPS`.<br>    (Required) `default_action_type` - The type of default routing action. Valid values are `FORWARD`, `FIXED_RESPONSE`, `REDIRECT_301` and `REDIRECT_302`.<br>    (Optional) `default_action_parameters` - Configuration block for the parameters of the default routing action.<br>    (Optional) `rules` - The rules that you define for the listener determine how the load balancer routes requests to the targets in one or more target groups.<br>    (Optional) `tls_certificate` - The ARN of the default SSL server certificate. For adding additional SSL certificates, see the `tls_additional_certificates` variable. Required if `protocol` is `HTTPS`.<br>    (Optional) `tls_additional_certificates` - A set of ARNs of the certificate to attach to the listener. This is for additional certificates and does not replace the default certificate on the listener.<br>    (Optional) `tls_security_policy` - The name of security policy for a Secure Socket Layer (SSL) negotiation configuration. This is used to negotiate SSL connections with clients. Required if protocol is `HTTPS`. Defaults to `ELBSecurityPolicy-2016-08` security policy. The `ELBSecurityPolicy-2016-08` security policy is always used for backend connections. Application Load Balancers do not support custom security policies. | `any` | `[]` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_network_mapping"></a> [network\_mapping](#input\_network\_mapping) | (Optional) The configuration for the load balancer how routes traffic to targets in which subnets, and in accordance with IP address settings. Select at least two Availability Zone and one subnet for each zone. The load balancer will route traffic only to targets in the selected Availability Zones. Zones that are not supported by the load balancer or VPC cannot be selected. Subnets can be added, but not removed, once a load balancer is created. Each key of `network_mapping` is the availability zone id like `apne2-az1`, `use1-az1`. Each value of `network_mapping` block as defined below.<br>    (Required) `subnet_id` - The id of the subnet of which to attach to the load balancer. You can specify only one subnet per Availability Zone. | `map(map(string))` | `{}` | no |
| <a name="input_resource_group_description"></a> [resource\_group\_description](#input\_resource\_group\_description) | (Optional) The description of Resource Group. | `string` | `"Managed by Terraform."` | no |
| <a name="input_resource_group_enabled"></a> [resource\_group\_enabled](#input\_resource\_group\_enabled) | (Optional) Whether to create Resource Group to find and group AWS resources which are created by this module. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. | `string` | `""` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | (Optional) A set of security group IDs to assign to the load balancer. | `set(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_waf_fail_open_enabled"></a> [waf\_fail\_open\_enabled](#input\_waf\_fail\_open\_enabled) | (Optional) Indicates whether to allow a WAF-enabled load balancer to route requests to targets if it is unable to forward the request to AWS WAF. Defaults to `false`. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_log"></a> [access\_log](#output\_access\_log) | The configuration for access logs of the load balancer. |
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the load balancer. |
| <a name="output_arn_suffix"></a> [arn\_suffix](#output\_arn\_suffix) | The ARN suffix for use with CloudWatch Metrics. |
| <a name="output_attributes"></a> [attributes](#output\_attributes) | Load Balancer Attributes that applied to the application load balancer. |
| <a name="output_availability_zone_ids"></a> [availability\_zone\_ids](#output\_availability\_zone\_ids) | A list of the Availability Zone IDs which are used by the load balancer. |
| <a name="output_available_availability_zone_ids"></a> [available\_availability\_zone\_ids](#output\_available\_availability\_zone\_ids) | A list of the Availability Zone IDs available to the current account and region. |
| <a name="output_default_security_group"></a> [default\_security\_group](#output\_default\_security\_group) | The default security group of the load balancer. |
| <a name="output_domain"></a> [domain](#output\_domain) | The DNS name of the load balancer. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the load balancer. |
| <a name="output_ip_address_type"></a> [ip\_address\_type](#output\_ip\_address\_type) | The type of IP addresses used by the subnets for your load balancer. |
| <a name="output_is_public"></a> [is\_public](#output\_is\_public) | Indicates whether the load balancer is public. |
| <a name="output_listeners"></a> [listeners](#output\_listeners) | The listeners of the application load balancer. |
| <a name="output_name"></a> [name](#output\_name) | The name of the load balancer. |
| <a name="output_network_mapping"></a> [network\_mapping](#output\_network\_mapping) | The configuration for the load balancer how routes traffic to targets in which subnets and IP address settings. |
| <a name="output_security_groups"></a> [security\_groups](#output\_security\_groups) | A set of security group IDs which is assigned to the load balancer. |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | A list of subnet IDs attached to the load balancer. |
| <a name="output_type"></a> [type](#output\_type) | The type of the load balancer. Always return `APPLICATION`. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The VPC ID of the load balancer. |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | The canonical hosted zone ID of the load balancer to be used in a Route 53 Alias record. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
