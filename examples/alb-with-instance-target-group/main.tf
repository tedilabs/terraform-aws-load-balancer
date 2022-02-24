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

  name = "tedilabs-alb-instance"

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
    name        = "tedilabs-alb-instance"
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
      rules = {
        10 = {
          conditions = [
            {
              type   = "HOST"
              values = ["*.tedilabs.com", "abc.tedilabs.com"]
            }
          ]
          action_type = "FORWARD"
          action_parameters = {
            target_group = module.target_group_alpha.name
          }
        }
        20 = {
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
                target_group = module.target_group_alpha.name
                weight       = 3
              },
              {
                target_group = module.target_group_beta.name
                weight       = 1
              },
            ]
          }
        }
      }
    },
  ]

  ## Access Log
  access_log_enabled       = false
  access_log_s3_bucket     = "my-bucket"
  access_log_s3_key_prefix = "/tedilabs-alb-instance/"

  tags = {
    "project" = "terraform-aws-load-balancer-examples"
  }

  depends_on = [
    module.target_group_alpha,
    module.target_group_beta,
  ]
}


###################################################
# Instance Target Group for Application Load Balancer
###################################################

module "target_group_alpha" {
  source = "../../modules/alb-instance-target-group"
  # source  = "tedilabs/load-balancer/aws//modules/alb-instance-target-group"
  # version = "~> 1.0.0"

  name = "tedilabs-alb-instance-alpha-tg"

  vpc_id = data.aws_vpc.default.id

  port             = 80
  protocol         = "HTTP"
  protocol_version = "HTTP1"

  ## Attributes
  deregistration_delay     = 300
  load_balancing_algorithm = "ROUND_ROBIN"
  slow_start_duration      = 0

  targets = [
    # {
    #   instance = "i-xxxx"
    # },
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
  source = "../../modules/alb-instance-target-group"
  # source  = "tedilabs/load-balancer/aws//modules/alb-instance-target-group"
  # version = "~> 1.0.0"

  name = "tedilabs-alb-instance-beta-tg"

  vpc_id = data.aws_vpc.default.id

  port             = 80
  protocol         = "HTTP"
  protocol_version = "HTTP1"

  ## Attributes
  deregistration_delay     = 300
  load_balancing_algorithm = "ROUND_ROBIN"
  slow_start_duration      = 0

  targets = [
    # {
    #   instance = "i-xxxx"
    # },
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
