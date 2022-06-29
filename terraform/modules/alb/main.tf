module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "7.0.0"

  name = "${var.mod_prefix}-alb-tf"

  load_balancer_type = "application"

  vpc_id             = var.vpc_id
  subnets            = var.public_subnets
  security_groups    = [module.security-group.security_group_id]

  target_groups = [for tg_def in var.target_group_definitions :
    {
      name      = tg_def.name
      backend_protocol = "HTTP"
      backend_port     = tg_def.port
      target_type      = "ip"
      health_check = {
        enabled = true
        path = tg_def.health_check
        port = tg_def.port
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP",
      fixed_response = {
        content_type = "text/plain"
        message_body = "Not found"
        status_code  = "404"
      }
    }
  ]

  http_tcp_listener_rules = [ for i, tg_def in var.target_group_definitions :
    {
      http_tcp_listener_index = 0
      priority                = i+1

      actions = [{
        type = "forward"
        target_group_index = i
      }]

      conditions = [{
        path_patterns = [tg_def.root_path]
      }]
    }
  ]


  tags = var.tags
}

module "security-group" {
  source = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "${var.mod_prefix}-alb-sg-tf"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks      = [var.vpc_cidr]
  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Http 80 port"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_rules = [ "all-all" ]

  tags = var.tags
}