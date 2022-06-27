module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"
  # insert the 23 required variables here

  name = "${var.prefix}-${var.environment}-vpc-tf"
  cidr = var.vpc_cidr

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  enable_dns_hostnames = true

  tags = {
    Terraform = "true"
    Environment = var.environment
    Owner = var.owner
  }

}

module "app_db_service_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "${var.prefix}-${var.environment}-app-db-service-sg-tf"
  description = "Security group for app db"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = [module.vpc.vpc_cidr_block]
  ingress_rules            = []
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "App db ports"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]
  egress_rules = [ "all-all" ]

  tags = {
    Terraform = "true"
    Environment = var.environment
    Owner = var.owner
  }
}

module "app_s3_service_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "${var.prefix}-${var.environment}-app-s3-service-sg-tf"
  description = "Security group for app s3"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = [module.vpc.vpc_cidr_block]
  ingress_rules            = []
  ingress_with_cidr_blocks = [
    {
      from_port   = 8081
      to_port     = 8081
      protocol    = "tcp"
      description = "App s3 ports"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]
  egress_rules = [ "all-all" ]

  tags = {
    Terraform = "true"
    Environment = var.environment
    Owner = var.owner
  }
}

module "rds_db_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "${var.prefix}-${var.environment}-rds-db-sg-tf"
  description = "Security group for rds"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = [module.vpc.vpc_cidr_block]
  ingress_rules            = []
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Rds DB ports"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]
  egress_rules = [ "all-all" ]

  tags = {
    Terraform = "true"
    Environment = var.environment
    Owner = var.owner
  }
}

module "alb_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "${var.prefix}-${var.environment}-alb-sg-tf"
  description = "Security group for rds"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = [module.vpc.vpc_cidr_block]
  ingress_rules            = []
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

  tags = {
    Terraform = "true"
    Environment = var.environment
    Owner = var.owner
  }
}


module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "4.4.0"

  identifier = "${var.prefix}-${var.environment}-rds-tf"

  engine            = "mysql"
  engine_version    = "8.0.28"
  instance_class    = "db.t3.micro"
  allocated_storage = 5

  db_name  = "db"
  username = "user"
  password = "user_secret_pw"
  port     = "3306"

  vpc_security_group_ids = [module.rds_db_sg.security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval = "30"
  monitoring_role_name = "${var.prefix}-${var.environment}-MyRDSMonitoringRole"
  create_monitoring_role = true

  # DB subnet group
  create_db_subnet_group = false
  db_subnet_group_name = module.vpc.database_subnet_group_name

  # DB parameter group
  family = "mysql8.0"

  # DB option group
  major_engine_version = "8.0"

  # Database Deletion Protection
  deletion_protection = false

  parameters = [
    {
      name = "character_set_client"
      value = "utf8mb4"
    },
    {
      name = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]

  tags = {
    Terraform = "true"
    Environment = var.environment
    Owner = var.owner
  }
}


module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "7.0.0"

  name = "${var.prefix}-${var.environment}-alb-tf"

  load_balancer_type = "application"

  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [module.alb_sg.security_group_id]

  target_groups = [
    {
      name_prefix      = "appDb-"
      backend_protocol = "HTTP"
      backend_port     = 8080
      target_type      = "ip"
      health_check = {
        enabled = true
        path = "/db/api/health"
        port = 8080
      }
    },
    {
      name_prefix      = "appS3-"
      backend_protocol = "HTTP"
      backend_port     = 8081
      target_type      = "ip"
      health_check = {
        enabled = true
        path = "/s3/api/health"
        port = 8081
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

  http_tcp_listener_rules = [
    {
      http_tcp_listener_index = 0
      priority                = 1

      actions = [{
        type = "forward"
        target_group_index = 0
      }]

      conditions = [{
        path_patterns = ["/db**"]
      }]
    },
    {
      http_tcp_listener_index = 0
      priority                = 2

      actions = [{
        type = "forward"
        target_group_index = 1
      }]

      conditions = [{
        path_patterns = ["/s3**"]
      }]
    }
  ]


  tags = {
    Terraform = "true"
    Environment = var.environment
    Owner = var.owner
  }
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  version = "4.0.2"

  cluster_name = "${var.prefix}-${var.environment}-ecs-fargate"

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
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = {
    Terraform = "true"
    Environment = var.environment
    Owner = var.owner
  }
}

data "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_cloudwatch_log_group" "app_db" {
  name       = "/ecs/${var.prefix}-${var.environment}-app-db-tf"
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "app_db" {
  family                = "${var.prefix}-${var.environment}-app-db-tf"
  container_definitions = file("task_def/app-db.json")
  network_mode          = "awsvpc"

  cpu    = 512
  memory = 1024

  requires_compatibilities = ["FARGATE"]

  task_role_arn = data.aws_iam_role.ecs_task_role.arn
  execution_role_arn = data.aws_iam_role.ecs_task_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
  }

  tags = {
    Terraform = "true"
    Environment = var.environment
    Owner = var.owner
  }
}

resource "aws_service_discovery_private_dns_namespace" "local" {
  name        = "${var.prefix}-${var.environment}.local"
  description = "Local domain"
  vpc         = module.vpc.vpc_id
}

resource "aws_service_discovery_service" "app_db_service_discovery" {
  name = "app-db-svc-tf"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.local.id

    dns_records {
      ttl  = 60
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

}

resource "aws_ecs_service" "app_db" {
  name            = "${var.prefix}-${var.environment}-app-db-svc-tf"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.app_db.arn

  desired_count = 2

  deployment_maximum_percent         = 150
  deployment_minimum_healthy_percent = 100

  network_configuration {
    subnets = module.vpc.private_subnets
    security_groups = [module.app_db_service_sg.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = module.alb.target_group_arns[0]
    container_name   = "aws-db"
    container_port   = 8080
  }

  service_registries {
    registry_arn = aws_service_discovery_service.app_db_service_discovery.arn
  }

  tags = {
    Terraform = "true"
    Environment = var.environment
    Owner = var.owner
  }
}

data "aws_iam_role" "ecs_task_role_with_s3" {
  name = "gstudzinski_ecsTaskExecutionRole_ext"
}


resource "aws_cloudwatch_log_group" "app_s3" {
  name       = "/ecs/${var.prefix}-${var.environment}-app-s3-tf"
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "app_s3" {
  family                = "${var.prefix}-${var.environment}-app-s3-tf"
  container_definitions = file("task_def/app-s3.json")
  network_mode          = "awsvpc"

  cpu    = 512
  memory = 1024

  requires_compatibilities = ["FARGATE"]

  task_role_arn = data.aws_iam_role.ecs_task_role_with_s3.arn
  execution_role_arn = data.aws_iam_role.ecs_task_role_with_s3.arn

  runtime_platform {
    operating_system_family = "LINUX"
  }

  tags = {
    Terraform = "true"
    Environment = var.environment
    Owner = var.owner
  }
}

resource "aws_service_discovery_service" "app_s3_service_discovery" {
  name = "app-s3-svc-tf"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.local.id

    dns_records {
      ttl  = 60
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

}

resource "aws_ecs_service" "app_s3" {
  name            = "${var.prefix}-${var.environment}-app-s3-svc-tf"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.app_s3.arn

  desired_count = 2

  deployment_maximum_percent         = 150
  deployment_minimum_healthy_percent = 100

  network_configuration {
    subnets = module.vpc.private_subnets
    security_groups = [module.app_s3_service_sg.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = module.alb.target_group_arns[1]
    container_name   = "aws-s3"
    container_port   = 8081
  }

  service_registries {
    registry_arn = aws_service_discovery_service.app_s3_service_discovery.arn
  }

  tags = {
    Terraform = "true"
    Environment = var.environment
    Owner = var.owner
  }
}
