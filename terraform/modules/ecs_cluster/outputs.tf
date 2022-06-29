output cluster_id {
  value = module.ecs.cluster_id
}

output service_discovery_namespace_id {
  value = aws_service_discovery_private_dns_namespace.this.id
}

output service_discovery_domain_name {
  value = aws_service_discovery_private_dns_namespace.this.name
}