locals {
  health_check = {
    enabled             = true
    healthy_threshold   = 2
    interval            = 15
    matcher             = "200-499"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "10.0.0"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "${var.vpc_cidr}"
    }
  }

  target_groups = {
    prod = {
      name_prefix          = "prod"
      protocol             = "HTTP"
      port                 = 80
      target_type          = "ip"
      create_attachment    = false
      deregistration_delay = 30
      health_check         = local.health_check
    }
    dev = {
      name_prefix          = "dev"
      protocol             = "HTTP"
      port                 = 80
      target_type          = "ip"
      create_attachment    = false
      deregistration_delay = 30
      health_check         = local.health_check
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      # Default action
      forward = {
        target_group_key = "prod"
      }

      # Rules
      rules = {
        dev = {
          conditions = [{
            path_pattern = { values = ["/dev/*", "/dev"] }
          }]
          actions = [{
            forward = {
              target_group_key = "dev"
            }
          }]
        }
      }

    }
  }
}

output "alb_dns" {
  value = module.alb.dns_name
}