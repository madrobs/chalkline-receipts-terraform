data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "platform" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = local.name
  })
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.platform.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(local.common_tags, {
    Name = "${local.name}-private-${count.index + 1}"
    Tier = "private"
  })
}

resource "aws_security_group" "service" {
  for_each = local.services

  name        = "${local.name}-${each.value.name}"
  description = "Traffic for ${each.value.name}"
  vpc_id      = aws_vpc.platform.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name    = "${local.name}-${each.value.name}"
    Service = each.value.name
  })
}

resource "aws_security_group_rule" "receipts_to_storage" {
  type                     = "ingress"
  from_port                = local.services.storage.port
  to_port                  = local.services.storage.port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.service["storage"].id
  source_security_group_id = aws_security_group.service["receipts"].id
  description              = "receipts-api calls chalkline-storage"
}
