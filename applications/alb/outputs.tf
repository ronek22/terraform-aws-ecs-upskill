output "db_app_target_group_arn" {
  value = aws_lb_target_group.main.0.arn
}

output "s3_app_target_group_arn" {
  value = aws_lb_target_group.main.1.arn
}

output "alb_dns_url" {
  value = aws_lb.main.dns_name
}