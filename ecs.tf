resource "aws_ecr_repository" "demo_app" {
  name         = "demo-app"
  force_delete = true
}

resource "aws_security_group" "ecs_services" {
  name        = "demo-ecs-services"
  description = "Allow ALB to reach ECS services"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [module.alb.security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "6.6.1"

  cluster_name = "demo-cluster"

  services = {
    prod = {
      enable_execute_command = true
      desired_count          = 0
      platform_version       = "LATEST"
      launch_type            = "FARGATE"

      cpu    = 512
      memory = 1024

      runtime_platform = {
        operating_system_family = "LINUX"
        cpu_architecture        = "ARM64"
      }

      container_definitions = {
        prod = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "${aws_ecr_repository.demo_app.repository_url}:latest"
          readonlyRootFilesystem = false
          portMappings = [{
            name          = "http"
            containerPort = 80
            hostPort      = 80
            protocol      = "tcp"
          }]
        }
      }

      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups["prod"].arn
          container_name   = "prod"
          container_port   = 80
        }
      }

      security_group_ids = [aws_security_group.ecs_services.id]
      subnet_ids         = module.vpc.private_subnets
    }

    dev = {
      enable_execute_command = true
      desired_count          = 0
      platform_version       = "LATEST"
      launch_type            = "FARGATE"

      cpu    = 256
      memory = 512

      runtime_platform = {
        operating_system_family = "LINUX"
        cpu_architecture        = "ARM64"
      }

      container_definitions = {
        dev = {
          cpu       = 256
          memory    = 512
          essential = true
          image     = "${aws_ecr_repository.demo_app.repository_url}:latest"
          readonlyRootFilesystem = false
          portMappings = [{
            name          = "http"
            containerPort = 80
            hostPort      = 80
            protocol      = "tcp"
          }]
        }
      }

      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups["dev"].arn
          container_name   = "dev"
          container_port   = 80
        }
      }

      security_group_ids = [aws_security_group.ecs_services.id]
      subnet_ids         = module.vpc.private_subnets
    }
  }

  depends_on = [module.vpc, module.alb]
}

output "ecr_repository_url" {
  value = aws_ecr_repository.demo_app.repository_url
}