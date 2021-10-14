variable "owner" {
  description = "Infra owner"
}

variable "cidr" {
  description = "CIDR block for the VPC."
}

variable "public_subnets" {
  description = "List of public subnets"
}

variable "public_subnets_names" {
  description = "List of public subnets names"
}

variable "private_subnets" {
  description = "List of private subnets"
}

variable "private_subnets_names" {
  description = "List of private subnets names"
}

variable "availability_zones" {
  description = "List of availability zones"
}