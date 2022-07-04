locals {
  app_prefix = "${var.mod_prefix}-app-s3"

  container_name = "app-s3"
}

resource "aws_ecs_service" "this" {
  name            = "${local.app_prefix}-svc-tf"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"

  desired_count = 2

  deployment_maximum_percent         = 150
  deployment_minimum_healthy_percent = 100

  network_configuration {
    subnets = var.private_subnets
    security_groups = [module.security_group.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = local.container_name
    container_port   = var.port
  }

  service_registries {
    registry_arn = aws_service_discovery_service.this.arn
  }

  tags = var.tags
}

resource "aws_ecs_task_definition" "this" {
  family                = "${local.app_prefix}-tf"
  container_definitions = templatefile("${path.module}/task-def.json.tmpl", {
    container_name = local.container_name,
    port = var.port,
    log_group_name = aws_cloudwatch_log_group.this.name,
    region = var.region,
    image = var.ecr_image,
    app_db_svc_url = "http://${var.app_db_svc_domain}:${var.app_db_svc_port}/db"
  })
  network_mode          = "awsvpc"

  cpu    = 512
  memory = 1024

  requires_compatibilities = ["FARGATE"]

  task_role_arn = var.ecs_execution_task_role_arn
  execution_role_arn = var.ecs_execution_task_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
  }

  tags = var.tags
}

resource "aws_service_discovery_service" "this" {
  name = "${local.app_prefix}-svc-tf"

  dns_config {
    namespace_id = var.service_discovery_namespace_id

    dns_records {
      ttl  = 60
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

}

module "security_group" {
  source = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "${local.app_prefix}-sg-tf"
  description = "Security group for app s3"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks      = [var.vpc_cidr]
  ingress_with_cidr_blocks = [
    {
      from_port   = var.port
      to_port     = var.port
      protocol    = "tcp"
      description = "App s3 ports"
      cidr_blocks = var.vpc_cidr
    }
  ]
  egress_rules = [ "all-all" ]

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "this" {
  name       = "/ecs/${local.app_prefix}-tf"
  retention_in_days = 1
}





