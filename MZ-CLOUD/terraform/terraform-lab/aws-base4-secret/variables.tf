variable "region" {
  default = "ap-southeast-1"
}

variable "team" {
  default = "pista"
}

variable "worker" {
  default = "worker"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "ami" {
  # Ubuntu 24.04 LTS ap-southeast-1 (x86)
  default = "ami-08d59269edddde222"
}
