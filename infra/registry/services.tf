resource "aws_service_discovery_service" "prometheus" {
  name = var.prometheus_service_name

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.service_registry.id

    dns_records {
      ttl  = 10
      type = "SRV"
    }
  }
}
