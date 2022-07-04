variable "region" {
  type = string
}

variable "mod_prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable ecs_cluster_id {
}

variable "vpc_id" {
}

variable "vpc_cidr" {
  type = string
}

variable private_subnets {
  type = list(string)
}

variable target_group_arn {
  type = string
}

variable service_discovery_namespace_id {
}

variable port {
  type = number
}

variable ecr_image {
  type = string
}

variable db_host {
  type = string
}

variable db_password {
  type = string
}

variable ecs_execution_task_role_arn {
  type = string
}