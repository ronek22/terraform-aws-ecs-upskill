variable "aws_region" {
  description = "The AWS region to deploy the resources into."
  default     = "eu-west-2"
}

variable "cidr" {
  description = "CIDR Block for VPC"
  default     = "10.0.0.0/16"
}

variable "owner" {
  description = "Owner in form of first letter of firstname and lastname"
  default     = "jronkiewicz"
}

variable "public_subnets" {
  description = "a list of CIDRs for public subnets in your VPC"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets_names" {
  description = "a list of names for public subnets in your VPC"
  default     = ["public-subnet-a", "public-subnet-b"]
}

variable "private_subnets" {
  description = "a list of CIDRs for private subnets in your VPC"
  default     = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "private_subnets_names" {
  description = "a list of names for private subnets in your VPC"
  default     = ["private-app-a", "private-app-b", "private-db-a", "private-db-b"]
}

variable "availability_zones" {
  description = "a list of availability_zones in your VPC"
  default     = ["eu-west-2a", "eu-west-2b"]
}

variable "repositories" {
  description = "List of repositories"
  default     = ["db-app", "db-nginx", "s3-app", "s3-nginx"]
}


variable "target_groups" {
  description = "List of target group names"
  default     = ["db-app", "s3-app"]
}

variable "health_check_paths" {
  description = "List of health check paths"
  default     = ["/db/health/", "/s3/health"]
}

variable "instance_type" {
  description = "Instance Type for EC2"
  default = "t2.micro"
}

variable "key_name" {
  description = "Key name for SSH access"
  default = "upskill_key"
}

