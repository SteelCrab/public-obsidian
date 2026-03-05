# CSP, 라이브러리, 버전 선언
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 리전 설정
provider "aws" {
  region = "ap-southeast-1"
}
