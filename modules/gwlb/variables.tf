variable "name" {
  description = "(Required) The name of the load balancer. This name must be unique within your AWS account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen."
  type        = string

  validation {
    condition     = length(var.name) <= 32
    error_message = "The name can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen."
  }
}

variable "network_mapping" {
  description = <<EOF
  (Optional) The configuration for the load balancer how routes traffic to targets in which subnets, and in accordance with IP address settings. Select at least one Availability Zone and one subnet for each zone. We recommend selecting at least two Availability Zones. The load balancer will route traffic only to targets in the selected Availability Zones. Zones that are not supported by the load balancer or VPC cannot be selected. Subnets can be added, but not removed, once a load balancer is created. Each key of `network_mapping` is the availability zone id like `apne2-az1`, `use1-az1`. Each value of `network_mapping` block as defined below.
    (Required) `subnet_id` - The id of the subnet of which to attach to the load balancer. You can specify only one subnet per Availability Zone.
  EOF
  type        = map(map(string))
  default     = {}
}

variable "cross_zone_load_balancing_enabled" {
  description = "(Optional) Cross-zone load balancing distributes traffic evenly across all targets in the Availability Zones enabled for the load balancer. Indicates whether to enable cross-zone load balancing. Defaults to `false`. Regional data transfer charges may apply when cross-zone load balancing is enabled."
  type        = bool
  default     = false
}

variable "deletion_protection_enabled" {
  description = "(Optional) Indicates whether deletion of the load balancer via the AWS API will be protected. Defaults to `false`."
  type        = bool
  default     = false
}

variable "listeners" {
  description = <<EOF
  (Optional) A list of listener configurations of the gateway load balancer. Listeners listen for connection requests using their `protocol` and `port`. Each value of `listener` block as defined below.
    (Required) `port` - The number of port on which the listener of load balancer is listening. Must be `6081`.
    (Required) `target_group` - The ARN of the target group to which to route traffic.
  EOF
  type = list(object({
    port         = number
    target_group = string
  }))
  default = []

  validation {
    condition     = length(var.listeners) <= 1
    error_message = "The Gateway Load Balancer is limited to a single listener."
  }
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}

variable "module_tags_enabled" {
  description = "(Optional) Whether to create AWS Resource Tags for the module informations."
  type        = bool
  default     = true
}


###################################################
# Resource Group
###################################################

variable "resource_group_enabled" {
  description = "(Optional) Whether to create Resource Group to find and group AWS resources which are created by this module."
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "(Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`."
  type        = string
  default     = ""
}

variable "resource_group_description" {
  description = "(Optional) The description of Resource Group."
  type        = string
  default     = "Managed by Terraform."
}
