variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "prefix" {
  type = string
}

variable "owner" {
  type = string
}

variable vpc_cidr {
  type = string
}

variable db_user {
  type = string
}

variable db_password {
  type = string
}

variable db_name {
  type = string
}

variable db_port {
  type = string
}

variable app_db_port {
  type = string
}

variable app_db_health {
  type = string
}

variable app_db_root_path {
  type = string
}

variable app_db_image {
  type = string
}

variable app_s3_port {
  type = string
}

variable app_s3_health {
  type = string
}

variable app_s3_root_path {
  type = string
}

variable app_s3_image {
  type = string
}
