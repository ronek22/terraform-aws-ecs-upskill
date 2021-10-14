variable "availability_zones" {
  description = "List of availability zones"
}

variable "subnets" {
  description = "List of subnets"
}

variable "security_groups" {
  description = "List of security groups attached to instance"
}

variable "owner" {
  description = "Owner of infra"
}

variable "instance_type" {
  description = "Instance Type for EC2"
}

variable "key_name" {
  description = "Key name for SSH access"
}