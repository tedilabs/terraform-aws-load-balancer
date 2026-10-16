###################################################
# WAF for Application Load Balancer
###################################################

resource "aws_wafv2_web_acl_association" "this" {
  count = var.waf.web_acl != null ? 1 : 0

  region = var.region

  resource_arn = aws_lb.this.arn
  web_acl_arn  = var.waf.web_acl
}
