resource "aws_lb" "main" {
  name               = "${var.owner}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_security_groups
  subnets            = var.subnets.*.id

  enable_deletion_protection = false

  tags = {
    Name  = "${var.owner}-alb"
    Owner = var.owner
  }
}

resource "aws_lb_target_group" "main" {
  count       = length(var.target_groups)
  name        = "${var.owner}-tg-${element(var.target_groups, count.index)}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_paths[count.index]
    unhealthy_threshold = "2"
  }

  tags = {
    Name  = "${var.owner}-tg-${element(var.target_groups, count.index)}"
    Owner = var.owner
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port = 80
  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404 Not Found"
      status_code = 404
    }
  }
}

resource "aws_lb_listener_rule" "db" {

  listener_arn = aws_lb_listener.http.arn
  priority = 100

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.main.0.arn
  }
  condition {
    path_pattern {
      values = ["/db*"]
    }
  }
}

resource "aws_lb_listener_rule" "s3" {

  listener_arn = aws_lb_listener.http.arn
  priority = 200

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.main.1.arn
  }
  condition {
    path_pattern {
      values = ["/s3*"]
    }
  }
}