variable "region" {
  type = string
}

variable "mod_prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable vpc_cidr {
  default = "10.0.0.0/16"
}