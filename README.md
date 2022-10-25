# terraform-aws-load-balancer

![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/tedilabs/terraform-aws-load-balancer?color=blue&sort=semver&style=flat-square)
![GitHub](https://img.shields.io/github/license/tedilabs/terraform-aws-load-balancer?color=blue&style=flat-square)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white&style=flat-square)](https://github.com/pre-commit/pre-commit)

Terraform module which creates security related resources on AWS.

- [alb](./modules/alb)
- [alb-instance-target-group](./modules/alb-instance-target-group)
- [alb-ip-target-group](./modules/alb-ip-target-group)
- [alb-lambda-target-group](./modules/alb-lambda-target-group)
- [alb-listener](./modules/alb-listener)
- [gwlb](./modules/gwlb)
- [gwlb-instance-target-group](./modules/gwlb-instance-target-group)
- [gwlb-ip-target-group](./modules/gwlb-ip-target-group)
- [nlb](./modules/nlb)
- [nlb-alb-target-group](./modules/nlb-alb-target-group)
- [nlb-instance-target-group](./modules/nlb-instance-target-group)
- [nlb-ip-target-group](./modules/nlb-ip-target-group)
- [nlb-listener](./modules/nlb-listener)


## Target AWS Services

Terraform Modules from [this package](https://github.com/tedilabs/terraform-aws-load-balancer) were written to manage the following AWS Services with Terraform.

- **AWS ELB (Elastic Load Balancing)**
  - ALB (Application Load Balancer)
    - Load Balancer
    - Listener
    - Target Group (Instance / IP / Lambda)
  - NLB (Network Load Balancer)
    - Load Balancer
    - Listener
    - Target Group (Instance / IP / ALB)
  - GWLB (Gateway Load Balancer)
    - Load Balancer
    - Listener
    - Target Group (Instance / IP)


## Examples

### ALB (Application Load Balancer)

- [ALB with Instance Target Group](./examples/alb-with-instance-target-group)
- [ALB with IP Target Group](./examples/alb-with-ip-target-group)

### NLB (Network Load Balancer)

- [NLB with Instance Target Group](./examples/nlb-with-instance-target-group)
- [NLB with IP Target Group](./examples/nlb-with-ip-target-group)
- [NLB with ALB Target Group](./examples/nlb-with-alb-target-group)

### GWLB (Gateway Load Balancer)

- [GWLB with Instance Target Group](./examples/gwlb-with-instance-target-group)
- [GWLB with IP Target Group](./examples/gwlb-with-ip-target-group)


## Self Promotion

Like this project? Follow the repository on [GitHub](https://github.com/tedilabs/terraform-aws-load-balancer). And if you're feeling especially charitable, follow **[posquit0](https://github.com/posquit0)** on GitHub.


## License

Provided under the terms of the [Apache License](LICENSE).

Copyright © 2022, [Byungjin Park](https://www.posquit0.com).
