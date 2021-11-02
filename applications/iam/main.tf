data "aws_caller_identity" "current" {}
# ROLES

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.owner}-ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect    = "Allow",
        Sid       = ""
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.owner}-ecsTaskRole"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect    = "Allow",
        Sid       = ""
      }
    ]
  })
}

# POLICIES

resource "aws_iam_policy" "s3bucket" {
  name        = "${var.owner}-task-policy-s3"
  description = "Policy that allows access to S3"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "s3:*",
        Resource = [var.bucket_arn, "${var.bucket_arn}/*"]
      }
    ]
  })
}

resource "aws_iam_policy" "parameters" {
  name        = "${var.owner}-task-policy-parameter-store"
  description = "Policy that allows access to path in Parameter store"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Sid      = "AccessSecrets",
        Effect   = "Allow",
        Action   = "ssm:GetParameters"
        Resource = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.owner}/*"
      }
    ]
  })
}

# ATTACH POLICIES TO ROLES

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-parameter-store-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.parameters.arn
}

resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.s3bucket.arn
}


