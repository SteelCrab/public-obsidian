# CSP, 라이브러리, 버전 선언
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# 리전 설정
provider "aws" {
  region = "ap-southeast-1"

  #기본 태그 
  default_tags {
    tags = {
      Username    = "pista",
      Team        = "team1",
      Project     = "MSP Last Project",
      Environment = "Op"
    }
  }



}
