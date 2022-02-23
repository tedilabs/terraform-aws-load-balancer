output "alb" {
  value = module.alb
}

output "target_group" {
  value = {
    alpha = module.target_group_alpha
    beta  = module.target_group_beta
  }
}
