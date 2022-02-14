# nlb

This module creates following resources.

- `aws_lb`
- `aws_lb_listener` (optional)
- `aws_lb_listener_certificate` (optional)

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_listener"></a> [listener](#module\_listener) | ../nlb-listener | n/a |

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
| <a name="input_access_log_enabled"></a> [access\_log\_enabled](#input\_access\_log\_enabled) | (Optional) Indicates whether to enable access logs. Defaults to `false`, even when bucket is specified. | `bool` | `false` | no |
| <a name="input_access_log_s3_bucket"></a> [access\_log\_s3\_bucket](#input\_access\_log\_s3\_bucket) | (Optional) The name of the S3 bucket used to store the access logs. | `string` | `null` | no |
| <a name="input_access_log_s3_key_prefix"></a> [access\_log\_s3\_key\_prefix](#input\_access\_log\_s3\_key\_prefix) | (Optional) The key prefix for the specified S3 bucket. | `string` | `null` | no |
| <a name="input_cross_zone_load_balancing_enabled"></a> [cross\_zone\_load\_balancing\_enabled](#input\_cross\_zone\_load\_balancing\_enabled) | (Optional) Cross-zone load balancing distributes traffic evenly across all targets in the Availability Zones enabled for the load balancer. Indicates whether to enable cross-zone load balancing. Defaults to `false`. Regional data transfer charges may apply when cross-zone load balancing is enabled. | `bool` | `false` | no |
| <a name="input_deletion_protection_enabled"></a> [deletion\_protection\_enabled](#input\_deletion\_protection\_enabled) | (Optional) Indicates whether deletion of the load balancer via the AWS API will be protected. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_ip_address_type"></a> [ip\_address\_type](#input\_ip\_address\_type) | (Optional) The type of IP addresses used by the subnets for your load balancer. The possible values are `IPV4` and `DUALSTACK`. | `string` | `"IPV4"` | no |
| <a name="input_is_public"></a> [is\_public](#input\_is\_public) | (Optional) Indicates whether the load balancer will be public. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_listeners"></a> [listeners](#input\_listeners) | (Optional) A list of listener configurations of the network load balancer. Listeners listen for connection requests using their `protocol` and `port`. Each value of `listener` block as defined below.<br>    (Required) `port` - The number of port on which the listener of load balancer is listening.<br>    (Required) `protocol` - The protocol for connections from clients to the load balancer. Valid values are `TCP`, `TLS`, `UDP` and `TCP_UDP`. Not valid to use `UDP` or `TCP_UDP` if dual-stack mode is enabled on the load balancer.<br>    (Required) `target_group` - The ARN of the target group to which to route traffic.<br>    (Optional) `tls_certificate` - The ARN of the default SSL server certificate. For adding additional SSL certificates, see the `tls_additional_certificates` variable. Required if `protocol` is `TLS`.<br>    (Optional) `tls_additional_certificates` - A set of ARNs of the certificate to attach to the listener. This is for additional certificates and does not replace the default certificate on the listener.<br>    (Optional) `tls_security_policy` - The name of security policy for a Secure Socket Layer (SSL) negotiation configuration. This is used to negotiate SSL connections with clients. Required if protocol is `TLS`. Recommend using the `ELBSecurityPolicy-TLS13-1-2-2021-06` security policy. This security policy includes TLS 1.3, which is optimized for security and performance, and is backward compatible with TLS 1.2.<br>    (Optional) `tls_alpn_policy` - The policy of the Application-Layer Protocol Negotiation (ALPN) to select. ALPN is a TLS extension that includes the protocol negotiation within the exchange of hello messages. Can be set if `protocol` is `TLS`. Valid values are `HTTP1Only`, `HTTP2Only`, `HTTP2Optional`, `HTTP2Preferred`, and `None`. Defaults to `None`. | `any` | `[]` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_network_mapping"></a> [network\_mapping](#input\_network\_mapping) | (Optional) The configuration for the load balancer how routes traffic to targets in which subnets, and in accordance with IP address settings. Select at least one Availability Zone and one subnet for each zone. We recommend selecting at least two Availability Zones. The load balancer will route traffic only to targets in the selected Availability Zones. Zones that are not supported by the load balancer or VPC cannot be selected. Subnets can be added, but not removed, once a load balancer is created. Each key of `network_mapping` is the availability zone id like `apne2-az1`, `use1-az1`. Each value of `network_mapping` block as defined below.<br>    (Required) `subnet_id` - The id of the subnet of which to attach to the load balancer. You can specify only one subnet per Availability Zone.<br>    (Optional) `private_ipv4_address` - A private ipv4 address within the subnet to assign to the internal load balancer.<br>    (Optional) `ipv6_address` - An ipv6 address within the subnet to assign to the internet-facing load balancer.<br>    (Optional) `allocation_id` - The allocation ID of the Elastic IP address. | `map(map(string))` | `{}` | no |
| <a name="input_resource_group_description"></a> [resource\_group\_description](#input\_resource\_group\_description) | (Optional) The description of Resource Group. | `string` | `"Managed by Terraform."` | no |
| <a name="input_resource_group_enabled"></a> [resource\_group\_enabled](#input\_resource\_group\_enabled) | (Optional) Whether to create Resource Group to find and group AWS resources which are created by this module. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_log"></a> [access\_log](#output\_access\_log) | The configuration for access logs of the load balancer. |
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the load balancer. |
| <a name="output_arn_suffix"></a> [arn\_suffix](#output\_arn\_suffix) | The ARN suffix for use with CloudWatch Metrics. |
| <a name="output_attributes"></a> [attributes](#output\_attributes) | Load Balancer Attributes that applied to the network load balancer. |
| <a name="output_availability_zone_ids"></a> [availability\_zone\_ids](#output\_availability\_zone\_ids) | A list of the Availability Zone IDs which are used by the load balancer. |
| <a name="output_available_availability_zone_ids"></a> [available\_availability\_zone\_ids](#output\_available\_availability\_zone\_ids) | A list of the Availability Zone IDs available to the current account and region. |
| <a name="output_domain"></a> [domain](#output\_domain) | The DNS name of the load balancer. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the load balancer. |
| <a name="output_ip_address_type"></a> [ip\_address\_type](#output\_ip\_address\_type) | The type of IP addresses used by the subnets for your load balancer. |
| <a name="output_is_public"></a> [is\_public](#output\_is\_public) | Indicates whether the load balancer is public. |
| <a name="output_listeners"></a> [listeners](#output\_listeners) | The listeners of the network load balancer. |
| <a name="output_name"></a> [name](#output\_name) | The name of the load balancer. |
| <a name="output_network_mapping"></a> [network\_mapping](#output\_network\_mapping) | The configuration for the load balancer how routes traffic to targets in which subnets and IP address settings. |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | A list of subnet IDs attached to the load balancer. |
| <a name="output_type"></a> [type](#output\_type) | The type of the load balancer. Always return `NETWORK`. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The VPC ID of the load balancer. |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | The canonical hosted zone ID of the load balancer to be used in a Route 53 Alias record. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
