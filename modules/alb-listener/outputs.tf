output "arn" {
  description = "The Amazon Resource Name (ARN) of the listener."
  value       = aws_lb_listener.this.arn
}

output "id" {
  description = "The ID of the listener."
  value       = aws_lb_listener.this.id
}

output "name" {
  description = "The name of the listener."
  value       = local.metadata.name
}

output "port" {
  description = "The port number on which the listener of load balancer is listening."
  value       = aws_lb_listener.this.port
}

output "protocol" {
  description = "The protocol for connections of the listener."
  value       = aws_lb_listener.this.protocol
}

output "default_action" {
  description = "The default action for traffic on this listener. Default action apply to traffic that does not meet the conditions of rules on your listener."
  value = {
    type = var.default_action_type
    forward = (var.default_action_type == "FORWARD"
      ? {
        target_group = [
          for target in [aws_lb_listener.this.default_action[0].target_group_arn] : {
            arn      = target
            name     = data.aws_lb_target_group.this[target].name
            port     = data.aws_lb_target_group.this[target].port
            protocol = data.aws_lb_target_group.this[target].protocol
          }
        ][0]
      }
      : null
    )
    weighted_forward = try({
      targets = [
        for target in aws_lb_listener.this.default_action[0].forward[0].target_group : {
          target_group = {
            arn      = target.arn
            name     = data.aws_lb_target_group.this[target.arn].name
            port     = data.aws_lb_target_group.this[target.arn].port
            protocol = data.aws_lb_target_group.this[target.arn].protocol
          }
          weight = target.weight
        }
      ]
      stickiness = {
        enabled  = aws_lb_listener.this.default_action[0].forward[0].stickiness[0].enabled
        duration = aws_lb_listener.this.default_action[0].forward[0].stickiness[0].duration
      }
    }, null)
    fixed_response = try({
      status_code  = aws_lb_listener.this.default_action[0].fixed_response[0].status_code
      content_type = aws_lb_listener.this.default_action[0].fixed_response[0].content_type
      data         = aws_lb_listener.this.default_action[0].fixed_response[0].message_body
    }, null)
    redirect = try({
      status_code = split("_", aws_lb_listener.this.default_action[0].redirect[0].status_code)[1]
      protocol    = aws_lb_listener.this.default_action[0].redirect[0].protocol
      host        = aws_lb_listener.this.default_action[0].redirect[0].host
      port        = aws_lb_listener.this.default_action[0].redirect[0].port
      path        = aws_lb_listener.this.default_action[0].redirect[0].path
      query       = aws_lb_listener.this.default_action[0].redirect[0].query
      url = format(
        "%s://%s:%s%s?%s",
        lower(aws_lb_listener.this.default_action[0].redirect[0].protocol),
        aws_lb_listener.this.default_action[0].redirect[0].host,
        aws_lb_listener.this.default_action[0].redirect[0].port,
        aws_lb_listener.this.default_action[0].redirect[0].path,
        aws_lb_listener.this.default_action[0].redirect[0].query,
      )
    }, null)
  }
}

output "tls" {
  description = "TLS configurations of the listener."
  value = local.tls_enabled ? {
    certificate = aws_lb_listener.this.certificate_arn
    additional_certificates = [
      for certificate in values(aws_lb_listener_certificate.this) :
      certificate.certificate_arn
    ]
    security_policy = aws_lb_listener.this.ssl_policy
  } : null
}

output "rules" {
  description = "The rules of the listener determine how the load balancer routes requests to the targets in one or more target groups."
  value = {
    for priority, rule in aws_lb_listener_rule.this :
    priority => {
      arn        = rule.arn
      priority   = rule.priority
      conditions = var.rules[rule.priority].conditions
      action = {
        type = var.rules[rule.priority].action_type
        forward = (var.rules[rule.priority].action_type == "FORWARD"
          ? {
            target_group = [
              for target in [rule.action[0].target_group_arn] : {
                arn      = target
                name     = data.aws_lb_target_group.this[target].name
                port     = data.aws_lb_target_group.this[target].port
                protocol = data.aws_lb_target_group.this[target].protocol
              }
            ][0]
          }
          : null
        )
        weighted_forward = try({
          targets = [
            for target in rule.action[0].forward[0].target_group : {
              target_group = {
                arn      = target.arn
                name     = data.aws_lb_target_group.this[target.arn].name
                port     = data.aws_lb_target_group.this[target.arn].port
                protocol = data.aws_lb_target_group.this[target.arn].protocol
              }
              weight = target.weight
            }
          ]
          stickiness = {
            enabled  = rule.action[0].forward[0].stickiness[0].enabled
            duration = rule.action[0].forward[0].stickiness[0].duration
          }
        }, null)
        fixed_response = try({
          status_code  = rule.action[0].fixed_response[0].status_code
          content_type = rule.action[0].fixed_response[0].content_type
          data         = rule.action[0].fixed_response[0].message_body
        }, null)
        redirect = try({
          status_code = split("_", rule.action[0].redirect[0].status_code)[1]
          protocol    = rule.action[0].redirect[0].protocol
          host        = rule.action[0].redirect[0].host
          port        = rule.action[0].redirect[0].port
          path        = rule.action[0].redirect[0].path
          query       = rule.action[0].redirect[0].query
          url = format(
            "%s://%s:%s%s?%s",
            lower(rule.action[0].redirect[0].protocol),
            rule.action[0].redirect[0].host,
            rule.action[0].redirect[0].port,
            rule.action[0].redirect[0].path,
            rule.action[0].redirect[0].query,
          )
        }, null)
      }
    }
  }
}
