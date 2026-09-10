resource "aws_service_discovery_private_dns_namespace" "platform" {
  name        = "${var.environment}.chalkline.internal"
  description = "Private service discovery for ${var.environment}"
  vpc         = aws_vpc.platform.id

  tags = local.common_tags
}

resource "aws_service_discovery_service" "service" {
  for_each = local.services

  name = each.value.name

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.platform.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = merge(local.common_tags, {
    Service = each.value.name
  })
}
