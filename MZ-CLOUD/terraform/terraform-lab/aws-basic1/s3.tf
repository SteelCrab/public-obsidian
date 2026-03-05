# S3 버킷 생성
resource "aws_s3_bucket" "pista-static" {
  bucket = "pista-static-website-${random_id.suffix.hex}"

  tags = {
    Name = "pista-static"
  }
}

# 랜덤 suffix (버킷 이름 전역 유니크)
resource "random_id" "suffix" {
  byte_length = 4
}

# 퍼블릭 액세스 허용
resource "aws_s3_bucket_public_access_block" "pista-static" {
  bucket = aws_s3_bucket.pista-static.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 정적 웹사이트 호스팅 설정
resource "aws_s3_bucket_website_configuration" "pista-static" {
  bucket = aws_s3_bucket.pista-static.id

  index_document {
    suffix = "index.html"
  }
}

# 퍼블릭 읽기 정책
resource "aws_s3_bucket_policy" "pista-static" {
  bucket = aws_s3_bucket.pista-static.id

  depends_on = [aws_s3_bucket_public_access_block.pista-static]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.pista-static.arn}/*"
      }
    ]
  })
}

# index.html 업로드
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.pista-static.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
}
