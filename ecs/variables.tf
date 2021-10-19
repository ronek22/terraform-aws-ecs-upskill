variable "container_cpu" {
  description = "How much CPU would be used by container"
}

variable "container_memory" {
  description = "How much memory would be used by container"
}

variable "owner" {
  description = "Owner of infra"
}

variable "execution_role_arn" {
  description = "Task execution role arn for ECS"
}
variable "s3_task_role_arn" {
  description = "Task role for S3 APP"
}
variable "s3_app_repository_url" {
  description = "S3 APP Repository"
}
variable "s3_app_version" {
  description = "Image version of S3 App"
}
variable "s3_app_environment" {
  description = "Env variables for S3 App"
}
variable "s3_nginx_repository_url" {
  description = "S3 Nginx Repository"
}

variable "s3_bucket_name" {
  description = "S3 Bucket Name"
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
variable "db_app_version" {
  description = "Image version for DB app"
}
variable "db_app_environment" {
  description = "Env variables for DB app"
}
variable "db_nginx_repository_url" {
  description = "Image version for Db nginx"
}

variable "db_name_arn" {
  default = "Database name ARN from Parameter Store"
}

variable "db_host_arn" {
  description = "Database host ARN from Parameter Store"
}

variable "db_user_arn" {
  description = "Database user ARN from Parameter Store"
}

variable "db_password_arn" {
  description = "Database password ARN from Parameter Store"
}

variable "db_port_arn" {
  description = "Database port ARN from Parameter Store"
}