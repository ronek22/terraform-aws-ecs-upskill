resource "random_password" "django_secret_key" {
  length           = 50
  special          = true
  min_special      = 5
  override_special = "!#$%^&*()-_=+[]{}<>:?"
  keepers          = {
    pass_version = 1
  }
}

# PUT SECRET KEY IN PARAMETER STORE INSTEAD SHOW IT EXPLICITLY IN TASK DEFINITION
resource "aws_ssm_parameter" "django_secret_key" {
  name        = "/${var.owner}/dbapp/secret"
  description = "Secret Key for CRUD app"
  type        = "SecureString"
  value       = random_password.django_secret_key.result
}

# LOG GROUPS
resource "aws_cloudwatch_log_group" "s3_app" {
  name = "/ecs/${var.owner}-task-s3-app"

  tags = {
    Name  = "${var.owner}-task-s3-app"
    Owner = var.owner
  }
}

resource "aws_cloudwatch_log_group" "s3_nginx" {
  name = "/ecs/${var.owner}-task-s3-nginx"

  tags = {
    Name  = "${var.owner}-task-s3-nginx"
    Owner = var.owner
  }
}

resource "aws_cloudwatch_log_group" "db_app" {
  name = "/ecs/${var.owner}-task-db-app"

  tags = {
    Name  = "${var.owner}-task-db-app"
    Owner = var.owner
  }
}

resource "aws_cloudwatch_log_group" "db_nginx" {
  name = "/ecs/${var.owner}-task-db-nginx"

  tags = {
    Name  = "${var.owner}-task-db-nginx"
    Owner = var.owner
  }
}

# SERVICE DISCOVERY

resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "jronkiewicz.com"
  description = "DNS Namespace for ECS Cluster"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "db" {

  name = "db"

  dns_config {

    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}


# TASK DEFINITIONS

resource "aws_ecs_task_definition" "s3_app" {
  family                   = "${var.owner}-task-s3-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.s3_task_role_arn

  container_definitions = templatefile("${path.module}/task_definitions/s3_service.json", {
    app_repository_url   = var.s3_app_repository_url,
    nginx_repository_url = var.s3_nginx_repository_url
    app_version          = var.s3_app_version,
    bucket_name          = var.s3_bucket_name,
    service_discovery    = "${aws_service_discovery_service.db.name}.${aws_service_discovery_private_dns_namespace.main.name}"
    app_log_group        = aws_cloudwatch_log_group.s3_app.name
    nginx_log_group      = aws_cloudwatch_log_group.s3_nginx.name
    region               = var.aws_region
  })


  tags = {
    Name  = "${var.owner}-task-s3-app"
    Owner = var.owner
  }
}


resource "aws_ecs_task_definition" "db_app" {
  family                   = "${var.owner}-task-db-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = var.execution_role_arn

  container_definitions = templatefile("${path.module}/task_definitions/db_service.json", {
    app_repository_url   = var.db_app_repository_url,
    nginx_repository_url = var.db_nginx_repository_url
    app_version          = var.db_app_version,
    secret_key           = aws_ssm_parameter.django_secret_key.arn,
    db                   = var.db_name_arn,
    db_user              = var.db_user_arn,
    db_password          = var.db_password_arn,
    db_host              = var.db_host_arn,
    sql_port             = var.db_port_arn
    app_log_group        = aws_cloudwatch_log_group.db_app.name
    nginx_log_group      = aws_cloudwatch_log_group.db_nginx.name
    region               = var.aws_region
  })

  volume {
    name = "static_volume"
  }

  tags = {
    Name  = "${var.owner}-task-s3-app"
    Owner = var.owner
  }
}


# CLUSTER

resource "aws_ecs_cluster" "main" {
  name = "${var.owner}-fargate-cluster"
  tags = {
    Name  = "${var.owner}-fargate-cluster"
    Owner = var.owner
  }
}


# ISSUE WITH ROLLING UPDATE
# https://github.com/hashicorp/terraform/issues/11253#issuecomment-277418993

resource "aws_ecs_service" "db" {
  name                               = "${var.owner}-db-app-service"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = "${aws_ecs_task_definition.db_app.family}:${aws_ecs_task_definition.db_app.revision}"
  desired_count                      = var.db_app_desired_count
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 60
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  platform_version                   = "1.3.0"

  network_configuration {
    security_groups  = var.db_app_security_group
    subnets          = var.app_subnets
    assign_public_ip = false
  }

  service_registries {
    registry_arn   = aws_service_discovery_service.db.arn
    container_name = "nginx"
  }

  load_balancer {
    target_group_arn = var.db_target_group
    container_name   = "nginx"
    container_port   = 80
  }

  # desired_count is ignored as it can change due to autoscaling policy
  lifecycle {
    ignore_changes = [desired_count]
  }

}


resource "aws_ecs_service" "s3" {
  name                               = "${var.owner}-s3-service"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = "${aws_ecs_task_definition.s3_app.family}:${aws_ecs_task_definition.s3_app.revision}"
  desired_count                      = var.s3_desired_count
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 60
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = var.s3_app_security_group
    subnets          = var.app_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.s3_target_group
    container_name   = "nginx"
    container_port   = 80
  }


}

resource "aws_appautoscaling_target" "db_fargate" {
  max_capacity = 4
  min_capacity = 1
  resource_id = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.db.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}

resource "aws_appautoscaling_policy" "db_fargate_cpu" {
  name = "db-cpu-autoscaling"
  policy_type = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.db_fargate.resource_id
  scalable_dimension = aws_appautoscaling_target.db_fargate.scalable_dimension
  service_namespace  = aws_appautoscaling_target.db_fargate.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 60
    scale_in_cooldown = 60
    scale_out_cooldown = 60
  }
}


