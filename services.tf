resource "aws_ecr_repository" "service" {
  for_each = local.services

  name                 = "chalkline/${each.value.name}"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.common_tags, {
    Service = each.value.name
  })
}

locals {
  task_roles = {
    receipts = aws_iam_role.receipts_api.arn
    storage  = aws_iam_role.storage.arn
    members  = aws_iam_role.member_api.arn
  }

  service_environment = {
    receipts = [
      {
        name  = "STORAGE_URL"
        value = "http://chalkline-storage.${var.environment}.chalkline.internal:4000"
      }
    ]
    storage = [
      {
        name  = "OBJECTS_BUCKET"
        value = aws_s3_bucket.receipts.id
      },
      {
        name  = "AWS_REGION"
        value = var.aws_region
      }
    ]
    members = [
      {
        name  = "ENVIRONMENT"
        value = var.environment
      }
    ]
  }
}

resource "aws_ecs_task_definition" "service" {
  for_each = local.services

  family                   = "${local.name}-${each.value.name}"
  cpu                      = each.key == "storage" ? 512 : 256
  memory                   = each.key == "storage" ? 1024 : 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = local.task_roles[each.key]

  container_definitions = jsonencode([
    {
      name      = each.value.name
      image     = "${aws_ecr_repository.service[each.key].repository_url}:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = each.value.port
          hostPort      = each.value.port
          protocol      = "tcp"
        }
      ]
      environment = local.service_environment[each.key]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.service[each.key].name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = each.value.name
        }
      }
    }
  ])

  tags = merge(local.common_tags, {
    Service = each.value.name
  })
}

resource "aws_ecs_service" "service" {
  for_each = local.services

  name            = each.value.name
  cluster         = aws_ecs_cluster.platform.id
  task_definition = aws_ecs_task_definition.service[each.key].arn
  desired_count   = each.value.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.service[each.key].id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.service[each.key].arn
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  tags = merge(local.common_tags, {
    Service = each.value.name
  })
}
