module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "4.4.0"

  identifier = "${var.mod_prefix}-rds-db-tf"

  engine            = "mysql"
  engine_version    = "8.0.28"
  instance_class    = var.instance_class
  allocated_storage = var.storage

  db_name  = var.db_name
  username = var.username
  password = var.password
  port     = var.port

  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval = "30"
  monitoring_role_name = "${var.mod_prefix}-MyRDSMonitoringRole"
  create_monitoring_role = true

  # DB subnet group
  create_db_subnet_group = false
  db_subnet_group_name = var.subnet_group_name

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

  tags = var.tags
}

module "security_group" {
  source = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "${var.mod_prefix}-rds-db-sg-tf"
  description = "Security group for DB"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks      = [var.vpc_cidr]
  ingress_with_cidr_blocks = [
    {
      from_port   = var.port
      to_port     = var.port
      protocol    = "tcp"
      description = "Rds DB ports"
      cidr_blocks = var.vpc_cidr
    }
  ]
  egress_rules = [ "all-all" ]

  tags = var.tags

}