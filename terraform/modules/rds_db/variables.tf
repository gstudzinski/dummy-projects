variable "mod_prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable instance_class {
  default = "db.t3.micro"
}

variable storage {
  default = 5
}

variable db_name {
  type = string
}

variable username {
  type = string
}

variable password {
  type = string
}

variable port {
  type = number
}

variable vpc_id {
}

variable vpc_cidr {
  type = string
}

variable subnet_group_name {
  type = string
}

