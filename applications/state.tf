terraform {
  backend "s3" {
    bucket         = "jronkiewicz-tfstate"
    dynamodb_table = "jronkiewicz-tfstate-lock"
    key = "terraform.tfstate"
    # cannot use variables here, so region is hardcoded
    region = "eu-west-2"
    encrypt = true
  }
}