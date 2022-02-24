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

  name = "tedilabs-nlb-alb"

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
  access_log_s3_key_prefix = "/tedilabs-nlb-alb/"

  tags = {
    "project" = "terraform-aws-load-balancer-examples"
  }
}


###################################################
# ALB Target Group for Network Load Balancer
###################################################

module "target_group" {
  source = "../../modules/nlb-alb-target-group"
  # source  = "tedilabs/load-balancer/aws//modules/nlb-alb-target-group"
  # version = "~> 1.0.0"

  name = "tedilabs-nlb-alb-tg"

  vpc_id = data.aws_vpc.default.id
  port   = 80

  targets = [
    {
      alb = module.alb.arn
    }
  ]

  health_check = {
    port                = 80
    protocol            = "HTTP"
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
    path                = "/ping"
  }

  tags = {
    "project" = "terraform-aws-load-balancer-examples"
  }

  depends_on = [
    module.alb,
  ]
}
