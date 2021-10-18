variable "container_cpu" {
  description = "How much CPU would be used by container"
}
variable "owner" {
  description = "Owner of infra"
}
variable "container_memory" {
  description = "How much memory would be used by container"
}
variable "execution_role_arn" {
  description = "Task execution role arn for ECS"
}
variable "task_role_arn" {
  description = "Task role for S3 APP"
}
variable "s3_app_repository_url" {
  description = "S3 APP Repository"
}
variable "s3-app-version" {
  description = "Image version of S3 App"
}
variable "s3_app_environment" {
  description = "Env variables for S3 App"
}
variable "s3_nginx_repository_url" {
  description = "S3 Nginx Repository"
}

variable "s3_desired_count" {
  description = "Desired Tasks in S3 Service"
}
variable "s3_app_security_group" {
  description = "Security Group for S3 App"
}
variable "s3_app_subnet" {
  description = "Subnets for S3 App"
}
variable "s3_target_group" {
  description = "Target Group for S3 App"
}

variable "db_app_repository_url" {
  description = "Repository for DB app"
}
variable "db-app-version" {
  description = "Image version for DB app"
}
variable "db_app_environment" {
  description = "Env variables for DB app"
}
variable "db_nginx_repository_url" {
  description = "Image version for Db nginx"
}