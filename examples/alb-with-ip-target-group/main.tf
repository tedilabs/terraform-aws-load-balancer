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
# Application Load Balancer
###################################################

module "alb" {
  source = "../../modules/alb"
  # source  = "tedilabs/load-balancer/aws//modules/alb"
  # version = "~> 1.0.0"

  name = "tedilabs-alb-ip"

  is_public       = false
  ip_address_type = "IPV4"
  vpc_id          = data.aws_vpc.default.id
  network_mapping = {
    for az, subnet in data.aws_subnet.default :
    az => {
      subnet_id = subnet.id
    }
  }

  default_security_group = {
    name        = "tedilabs-alb-ip"
    description = "Managed by Terraform."

    ingress_cidrs = ["10.0.0.0/8", "172.31.0.0/16"]
  }
  security_groups = []

  ## Attributes
  desync_mitigation_mode      = "DEFENSIVE"
  drop_invalid_header_fields  = false
  deletion_protection_enabled = false
  http2_enabled               = true
  waf_fail_open_enabled       = false
  idle_timeout                = 60

  listeners = [
    {
      port                = 80
      protocol            = "HTTP"
      default_action_type = "REDIRECT_301"
      default_action_parameters = {
        protocol = "HTTPS"
        port     = 443
      }
    },
    {
      port                = 8080
      protocol            = "HTTP"
      default_action_type = "FIXED_RESPONSE"
      default_action_parameters = {
        content_type = "application/json"
        status_code  = 404
        data         = <<EOF
        {"status":"fail","metadata":{"statusCode":"404","code":"UNKNOWN_ENDPOINT","description":"The requested endpoint does not exist."}}
        EOF
      }
      rules = [
        {
          priority = 10
          conditions = [
            {
              type   = "HOST"
              values = ["*.tedilabs.com", "abc.tedilabs.com"]
            }
          ]
          action_type = "FORWARD"
          action_parameters = {
            target_group = module.target_group_alpha.arn
          }
        },
        {
          priority = 20
          conditions = [
            {
              type   = "HOST"
              values = ["my-service.dev.tedilabs.com"]
            }
          ]
          action_type = "WEIGHTED_FORWARD"
          action_parameters = {
            targets = [
              {
                target_group = module.target_group_alpha.arn
                weight       = 3
              },
              {
                target_group = module.target_group_beta.arn
                weight       = 1
              },
            ]
          }
        }
      ]
    },
  ]

  ## Access Log
  access_log_enabled       = false
  access_log_s3_bucket     = "my-bucket"
  access_log_s3_key_prefix = "/tedilabs-alb-ip/"

  tags = {
    "project" = "terraform-aws-load-balancer-examples"
  }
}


###################################################
# IP Target Group for Application Load Balancer
###################################################

module "target_group_alpha" {
  source = "../../modules/alb-ip-target-group"
  # source  = "tedilabs/load-balancer/aws//modules/alb-ip-target-group"
  # version = "~> 1.0.0"

  name = "tedilabs-alb-ip-alpha-tg"

  vpc_id = data.aws_vpc.default.id

  port             = 80
  protocol         = "HTTP"
  protocol_version = "HTTP1"

  ## Attributes
  deregistration_delay     = 300
  load_balancing_algorithm = "ROUND_ROBIN"
  slow_start_duration      = 0

  stickiness_enabled  = true
  stickiness_type     = "LB_COOKIE"
  stickiness_duration = 86400

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
    healthy_threshold   = 5
    unhealthy_threshold = 2
    path                = "/health"
  }

  tags = {
    "project" = "terraform-aws-load-balancer-examples"
  }
}

module "target_group_beta" {
  source = "../../modules/alb-ip-target-group"
  # source  = "tedilabs/load-balancer/aws//modules/alb-ip-target-group"
  # version = "~> 1.0.0"

  name = "tedilabs-alb-ip-beta-tg"

  vpc_id = data.aws_vpc.default.id

  port             = 80
  protocol         = "HTTP"
  protocol_version = "HTTP1"

  ## Attributes
  deregistration_delay     = 300
  load_balancing_algorithm = "ROUND_ROBIN"
  slow_start_duration      = 0

  stickiness_enabled  = true
  stickiness_type     = "APP_COOKIE"
  stickiness_duration = 86400
  stickiness_cookie   = "X-TEDILABS-SESSION"

  targets = [
    {
      ip_address = "10.234.1.234"
    },
  ]

  health_check = {
    port                = 80
    protocol            = "HTTP"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    path                = "/health"
  }

  tags = {
    "project" = "terraform-aws-load-balancer-examples"
  }
}
