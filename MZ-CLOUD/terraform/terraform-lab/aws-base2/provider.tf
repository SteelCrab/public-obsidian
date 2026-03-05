terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"

  default_tags {
    tags = {
      Username    = "pista"
      Team        = "team1"
      Project     = "MSP Last Project"
      Environment = "Op"
    }
  }
}
