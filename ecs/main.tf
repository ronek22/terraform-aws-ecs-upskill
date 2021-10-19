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

resource "aws_ecs_task_definition" "s3_app" {
  family                   = "${var.owner}-task-s3-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.s3_task_role_arn
  container_definitions    = templatefile("./task_definitions/s3_service.json", {
    app_repository_url   = var.s3_app_repository_url,
    app_version          = var.s3_app_version,
    bucket_name          = var.s3_bucket_name,
    service_discovery    = "localhost", # TODO: service discovery dns
    nginx_repository_url = var.s3_nginx_repository_url
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
  container_definitions    = templatefile("./task_definitions/db_service.json", {
    app_repository_url   = var.db_app_repository_url,
    app_version          = var.db_app_version,
    nginx_repository_url = var.db_nginx_repository_url
    secret_key           = aws_ssm_parameter.django_secret_key.arn,
    db                   = var.db_name_arn,
    db_user              = var.db_user_arn,
    db_password          = var.db_password_arn,
    db_host              = var.db_host_arn,
    sql_port             = var.db_port_arn
  })

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