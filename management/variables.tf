variable "aws_region" {
  description = "AWS Region for infrastructure"
  default     = "eu-west-2"
}

variable "owner" {
  description = "Owner of infra"
  default = "jronkiewicz"
}

variable "repositories" {
  description = "List of repositories"
  default     = ["db-app", "db-nginx", "s3-app", "s3-nginx"]
}