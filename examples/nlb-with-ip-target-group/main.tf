provider "aws" {
  region = "us-east-1"
}


data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default" {
  for_each = toset(["use1-az1", "use1-az2"])

  availability_zone_id = each.key
  default_for_az       = true
}


###################################################
# Network Load Balancer
###################################################

module "nlb" {
  source = "../../modules/nlb"
  # source  = "tedilabs/load-balancer/aws//modules/nlb"
  # version = "~> 1.0.0"

  name = "tedilabs-nlb-ip"

  is_public       = false
  ip_address_type = "IPV4"
  network_mapping = {
    for az, subnet in data.aws_subnet.default :
    az => {
      subnet_id = subnet.id
    }
  }

  ## Attributes
  cross_zone_load_balancing_enabled = true
  deletion_protection_enabled       = false

  listeners = [{
    port         = 80
    protocol     = "TCP"
    target_group = module.target_group.arn
  }]

  access_log_enabled       = false
  access_log_s3_bucket     = "my-bucket"
  access_log_s3_key_prefix = "/tedilabs-nlb-ip/"

  tags = {
    "project" = "terraform-aws-load-balancer-examples"
  }
}


###################################################
# IP Target Group for Network Load Balancer
###################################################

module "target_group" {
  source = "../../modules/nlb-ip-target-group"
  # source  = "tedilabs/load-balancer/aws//modules/nlb-ip-target-group"
  # version = "~> 1.0.0"

  name = "tedilabs-nlb-ip-tg"

  vpc_id = data.aws_vpc.default.id

  port     = 80
  protocol = "TCP"

  ## Attributes
  terminate_connection_on_deregistration = false
  deregistration_delay                   = 300
  preserve_client_ip                     = true
  proxy_protocol_v2                      = false
  stickiness_enabled                     = true

  targets = [
    {
      ip_address = "10.123.123.234"
    },
    {
      ip_address = "10.0.103.34"
      port       = 999
    },
  ]

  health_check = {
    port                = 80
    protocol            = "HTTP"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    path                = "/health"
  }

  tags = {
    "project" = "terraform-aws-load-balancer-examples"
  }
}
