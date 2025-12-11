terraform {
  required_version = "~>1.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket = "svitlana-terraform-state-bucket"
    region = "eu-central-1"
    key    = "svitlana/terraform.tfstate"

    use_lockfile = true
  }
}
provider "aws" {
  region  = var.aws_region
  profile = "default"
}

