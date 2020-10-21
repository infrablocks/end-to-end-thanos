output "service_discovery_namespace_id" {
  value = aws_service_discovery_private_dns_namespace.service_registry.id
}

output "service_discovery_namespace_arn" {
  value = aws_service_discovery_private_dns_namespace.service_registry.arn
}

output "service_discovery_namespace_hosted_zone_id" {
  value = aws_service_discovery_private_dns_namespace.service_registry.hosted_zone
}

output "service_discovery_prometheus_service_registry_arn" {
  value = aws_service_discovery_service.prometheus.arn
}

output "service_discovery_prometheus_address" {
  value = "${var.prometheus_service_name}.${local.service_registry_domain_name}"
}
