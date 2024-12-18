terraform {
  backend "s3" {
    bucket = "phonqpvt1-local.backend-remote-tfstate"
    key    = "851725403398/run-atlantis-demo/ap-southeast-1/state.tfstate"
    region = "ap-southeast-1"
    dynamodb_table = "phonqpvt1-local.backend-remote-tfstate-lock"
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  default = "ap-southeast-1"
}