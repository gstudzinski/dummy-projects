module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  version = "4.0.2"

  cluster_name = "${var.mod_prefix}-fargate-cluster"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-fargate"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  tags = var.tags
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = "${var.mod_prefix}.local"
  description = "${var.mod_prefix} Local domain"
  vpc         = var.vpc_id

  tags = var.tags
}