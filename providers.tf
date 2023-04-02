terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket         = "tfstate"
    key            = "terraform.tfstate"
    region         = "eu-west-3" 
    encrypt        = true
    dynamodb_table = "terraform_lock"
  }
}

provider "aws" {
  region = "us-east-1"
}