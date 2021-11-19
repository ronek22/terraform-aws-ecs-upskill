variable "owner" {
  description = "Owner of infra"
}

variable "PREFIX" {
    default = "github-runner"
}

variable "vpc_cidr" {
    description = "CIDR for the VPC"
    default = "20.0.0.0/16"
}

variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "20.0.0.0/24"
}

variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "20.0.255.0/24"
}