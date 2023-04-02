terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    region = "us-west-1"
    key    = "terraform.tfstate"
  }

  # backend "s3" {
  #   bucket         = "tfstate"
  #   key            = "terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "tflock"
  # }
}

provider "aws" {
  region = "us-east-1"
}