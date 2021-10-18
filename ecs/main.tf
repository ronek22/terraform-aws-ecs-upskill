resource "aws_ecs_task_definition" "s3_app" {
  family                   = "${var.owner}-task-s3-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  container_definitions    = jsonencode([
    {
      name         = "app",
      image        = "${var.s3_app_repository_url}:${var.s3-app-version}"
      essential    = true
      environment  = var.s3_app_environment
      portMappings = [
        {
          protocol       = "tcp"
          container_port = 5000
        }
      ]
    },
    {
      name         = "nginx"
      image        = "${var.s3_nginx_repository_url}:${var.s3-app-version}"
      essential    = true
      portMappings = [
        {
          protocol       = "tcp"
          container_port = 80
          host_port      = 80
        }
      ]
    }
  ])

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
  container_definitions    = jsonencode([
    {
      name         = "app",
      image        = "${var.db_app_repository_url}:${var.db-app-version}"
      essential    = true
      environment  = var.db_app_environment
      portMappings = [
        {
          protocol       = "tcp"
          container_port = 8000
        }
      ]
    },
    {
      name         = "nginx"
      image        = "${var.db_nginx_repository_url}:${var.db-app-version}"
      essential    = true
      portMappings = [
        {
          protocol       = "tcp"
          container_port = 80
          host_port      = 80
        }
      ]
    }
  ])

  tags = {
    Name  = "${var.owner}-task-s3-app"
    Owner = var.owner
  }
}

resource "aws_ecs_cluster" "main" {
  name = "${var.owner}-fargate-cluster"
  tags = {
    Name  = "${var.owner}-fargate-cluster"
    Owner = var.owner
  }
}


resource "aws_ecs_service" "s3" {
  name                              = "${var.owner}-s3-service"
  cluster                           = aws_ecs_cluster.main
  task_definition                   = aws_ecs_task_definition.s3_app.arn
  desired_count                     = var.s3_desired_count
  deployment_minimum_health_percent = 50
  deployment_maximum_percent        = 200
  health_check_grace_period_seconds = 60
  launch_type                       = "FARGATE"
  scheduling_strategy               = "REPLICA"

  network_configuration {
    security_groups  = var.s3_app_security_group
    subnets          = var.s3_app_subnet
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.s3_target_group
    container_name   = "app"
    container_port   = 80
  }

}