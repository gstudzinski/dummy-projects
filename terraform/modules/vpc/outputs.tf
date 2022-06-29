output vpc_id {
  value = module.vpc.vpc_id
}

output database_subnet_group_name {
  value = module.vpc.database_subnet_group_name
}

output public_subnets {
  value = module.vpc.public_subnets
}

output private_subnets {
  value = module.vpc.private_subnets
}