variable "owner" {
  description = "Infra owner"
}

variable "alb_security_groups" {
  description = "Comma separated list of security groups"
}

variable "subnets" {
  description = "Comma separated list of subnet IDs"
}

variable "target_groups" {
  description = "List of target group names"
}

variable "health_check_paths" {
  description = "List of health check paths"
}

variable "vpc_id" {
  description = "The VPC ID"
}