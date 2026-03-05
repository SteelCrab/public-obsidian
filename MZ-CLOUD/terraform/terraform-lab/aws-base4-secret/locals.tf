# 
locals {
  service_name = "${var.team}-${var.worker}-ec2"
  common_tags = {
    Project_name = local.service_name
    Managed      = "Terraform"
  }
}
output "service_name" {
  value = local.service_name
}

