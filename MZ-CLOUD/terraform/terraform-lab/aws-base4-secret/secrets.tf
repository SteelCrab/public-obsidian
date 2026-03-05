# aws/secretsmanager
# mysql/admin/password

resource "aws_secretsmanager_secret" "db_pass" {
  name        = "db/admin/password"
  description = "RDS_DB_PASSWORD"
}

resource "aws_secretsmanager_secret_version" "db_pass_val" {
  secret_id     = aws_secretsmanager_secret.db_pass.id
  secret_string = "wjsansrk"
}

# 비밀번호 정보 검색 
data "aws_secretsmanager_secret" "search" {
  name = "mysql/admin/password"
}

# 검색된 비밀번호의 실제 값을 가져옴 
data "aws_secretsmanager_secret_version" "search_val" {
  secret_id = data.aws_secretsmanager_secret.search.search.secret_id
}

output "secret_show" {
  value     = data.aws_secretsmanager_secret_version.search_val.secret_string
  sensitive = true
}
