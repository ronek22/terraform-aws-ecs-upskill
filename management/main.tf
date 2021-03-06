provider "aws" {
  region = var.aws_region
}

module "ecr" {
  source       = "./ecr"
  owner        = var.owner
  repositories = var.repositories
}

module "state" {
  source = "./state"
  owner  = var.owner
}

module "self-hosted-runner" {
  source = "./self-hosted-runner"
  owner  = var.owner
}
