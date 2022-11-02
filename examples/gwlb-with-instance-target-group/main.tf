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
# Gateway Load Balancer
###################################################

module "gwlb" {
  source = "../../modules/gwlb"
  # source  = "tedilabs/load-balancer/aws//modules/gwlb"
  # version = "~> 1.0.0"

  name = "tedilabs-gwlb-instance"
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
    port         = 6081
    target_group = module.target_group.arn
  }]

  tags = {
    "project" = "terraform-aws-load-balancer-examples"
  }
}


###################################################
# Instance Target Group for Gateway Load Balancer
###################################################

module "target_group" {
  source = "../../modules/gwlb-instance-target-group"
  # source  = "tedilabs/load-balancer/aws//modules/gwlb-instance-target-group"
  # version = "~> 1.0.0"

  name = "tedilabs-gwlb-instance-tg"

  vpc_id = data.aws_vpc.default.id

  targets = [
    # {
    #   instance = "i-xxxx"
    # },
  ]

  health_check = {
    protocol      = "HTTP"
    port          = 80
    port_override = true
    path          = "/health"

    interval            = 10
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}
