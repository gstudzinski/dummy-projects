variable "mod_prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "vpc_id" {
}

variable "vpc_cidr" {
  type = string
}

variable public_subnets {
  type = list(string)
}

variable "target_group_definitions" {
  type = list(object({
    name         = string
    port         = string
    health_check = string
    root_path    = string
  }))
}