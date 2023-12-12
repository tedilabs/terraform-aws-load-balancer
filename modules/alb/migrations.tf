# INFO: 2023-12-11 - Make optional `security_group` module
moved {
  from = module.security_group
  to   = module.security_group[0]
}

# 2022-10-20
moved {
  from = aws_resourcegroups_group.this[0]
  to   = module.resource_group[0].aws_resourcegroups_group.this
}
