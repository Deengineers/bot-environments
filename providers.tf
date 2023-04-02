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
    region         = "us-east-1" # Change this to the region where your S3 bucket is located
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

provider "aws" {
  region = "us-east-1"
}