terraform {
  backend "s3" {
    bucket = "phonqpvt1-local.backend-remote-tfstate"
    key    = "851725403398/run-atlantis-demo/default/state.tfstate"
    region = "ap-southeast-1"
    dynamodb_table = "phonqpvt1-local.backend-remote-tfstate-lock"
  }
}

provider "aws" {
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::851725403398:role/spacelift"
  }
}

variable "region" {
  default = "ap-southeast-1"
}