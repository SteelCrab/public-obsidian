terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # 팀 공유 상태 파일 설정 (팀원 전체 동일하게 유지)
  backend "s3" {
    bucket       = "pista-tf-state-bucket"         # 팀 공유 S3 버킷 이름
    key          = "aws-base6-3tier/terraform.tfstate"
    region       = "ap-southeast-1"
    encrypt      = true        # 상태파일 암호화 (비정상 접속 보호)
    use_lockfile = true        # 동시 수정 방지 (Terraform >= 1.10 필요)
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
