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
          for target in [var.default_action_parameters.target_group] : {
            arn  = target
            name = split("/", target)[1]
          }
        ][0]
      }
      : null
    )
    weighted_forward = try({
      targets = [
        for target in var.default_action_parameters.targets : {
          target_group = {
            arn  = target.target_group
            name = split("/", target.target_group)[1]
          }
          weight = try(target.weight, 1)
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

locals {
  output_rules = {
    for rule in var.rules :
    rule.priority => {
      conditions = rule.conditions
      action = {
        type           = rule.action_type
        parameters     = rule.action_parameters
        forward        = try(aws_lb_listener_rule.this[rule.priority].action[0].forward[0], null)
        fixed_response = try(aws_lb_listener_rule.this[rule.priority].action[0].fixed_response[0], null)
        redirect       = try(aws_lb_listener_rule.this[rule.priority].action[0].redirect[0], null)
      }
    }
  }
}

output "rules" {
  description = "The rules of the listener determine how the load balancer routes requests to the targets in one or more target groups."
  value = {
    for priority, rule in local.output_rules :
    priority => {
      conditions = rule.conditions
      action = {
        type = rule.action.type
        forward = (rule.action.type == "FORWARD"
          ? {
            target_group = {
              arn  = rule.action.parameters.target_group
              name = split("/", rule.action.parameters.target_group)[1]
            }
          }
          : null
        )
        weighted_forward = (rule.action.type == "WEIGHTED_FORWARD"
          ? {
            targets = [
              for target in rule.action.parameters.targets : {
                target_group = {
                  arn  = target.target_group
                  name = split("/", target.target_group)[1]
                }
                weight = try(target.weight, 1)
              }
            ]
            stickiness = {
              enabled  = rule.action.forward.stickiness[0].enabled
              duration = rule.action.forward.stickiness[0].duration
            }
          }
          : null
        )
        fixed_response = (rule.action.type == "FIXED_RESPONSE"
          ? {
            status_code  = rule.action.fixed_response.status_code
            content_type = rule.action.fixed_response.content_type
            data         = rule.action.fixed_response.message_body
          }
          : null
        )
        redirect = (contains(["REDIRECT_301", "REDIRECT_302"], rule.action.type)
          ? {
            status_code = split("_", rule.action.redirect.status_code)[1]
            protocol    = rule.action.redirect.protocol
            host        = rule.action.redirect.host
            port        = rule.action.redirect.port
            path        = rule.action.redirect.path
            query       = rule.action.redirect.query
            url = format(
              "%s://%s:%s%s?%s",
              lower(rule.action.redirect.protocol),
              rule.action.redirect.host,
              rule.action.redirect.port,
              rule.action.redirect.path,
              rule.action.redirect.query,
            )
          }
          : null
        )
      }
    }
  }
}
