###################################################
# Application Load Balancer
###################################################

module "alb" {
  source = "../../modules/alb"
  # source  = "tedilabs/load-balancer/aws//modules/alb"
  # version = "~> 1.0.0"

  name = "tedilabs-nlb-alb-alb"

  is_public       = false
  ip_address_type = "IPV4"
  vpc_id          = data.aws_vpc.default.id
  network_mapping = {
    for az, subnet in data.aws_subnet.default :
    az => {
      subnet = subnet.id
    }
  }

  default_security_group = {
    enabled     = true
    name        = "tedilabs-nlb-alb-alb"
    description = "Managed by Terraform."

    listener_ingress_ipv4_cidrs = ["10.0.0.0/8", "172.31.0.0/16"]
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
      rules = [
        {
          priority = 10
          conditions = [
            {
              type   = "PATH"
              values = ["/ping"]
            }
          ]
          action_type = "FIXED_RESPONSE"
          action_parameters = {
            status_code  = 200
            content_type = "application/json"
            data         = <<EOF
            {"status":"success","metadata":{"statusCode":"200"}}
            EOF
          }
        }
      ]
    },
    # {
    #   port         = 443
    #   protocol     = "HTTPS"
    #   default_action_type = "FIXED_RESPONSE"
    #   default_action_parameters = {
    #     content_type = "application/json"
    #     status_code  = 404
    #     data         = <<EOF
    #     {"status":"fail","metadata":{"statusCode":"404","code":"UNKNOWN_ENDPOINT","description":"The requested endpoint does not exist."}}
    #     EOF
    #   }
    # },
  ]

  ## Access Log
  access_log = {
    enabled = false
    s3_bucket = {
      name       = "my-bucket"
      key_prefix = "/tedilabs-nlb-alb-alb/"
    }
  }

  tags = {
    "project" = "terraform-aws-load-balancer-examples"
  }
}
