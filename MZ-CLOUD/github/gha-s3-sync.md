# GitHub Actions S3 동기화

#github #actions #s3 #aws #sync #upload

---

AWS S3 버킷에 파일 업로드 및 동기화.

## aws s3 cp

```yaml
- name: Upload to S3
  run: |
    aws s3 cp ./file.txt s3://bucket-name/path/file.txt
```

## aws s3 sync

```yaml
- name: Sync to S3
  run: |
    aws s3 sync ./dist/ s3://bucket-name/dist/
```

## 전체 워크플로우

```yaml
- uses: actions/checkout@v4

- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ${{ secrets.AWS_REGION }}

- name: Sync static files to S3
  run: |
    aws s3 sync ./public/ s3://${{ secrets.S3_BUCKET_NAME }}/public/ --delete
```

## 명령어 비교

| 명령어 | 설명 |
|--------|------|
| `aws s3 cp` | 단일 파일 복사 |
| `aws s3 sync` | 디렉토리 동기화 (변경된 파일만) |
| `aws s3 mv` | 파일 이동 (원본 삭제) |
| `aws s3 rm` | 파일 삭제 |

## 주요 옵션

| 옵션 | 설명 |
|------|------|
| `--delete` | 로컬에 없는 파일 S3에서 삭제 |
| `--exclude` | 제외할 패턴 |
| `--include` | 포함할 패턴 |
| `--acl` | ACL 설정 (public-read 등) |
| `--cache-control` | 캐시 제어 헤더 |
| `--dryrun` | 실제 실행 없이 테스트 |

## 정적 웹사이트 배포

```yaml
- name: Deploy to S3
  run: |
    aws s3 sync ./build/ s3://${{ secrets.S3_BUCKET_NAME }}/ \
      --delete \
      --cache-control "max-age=3600" \
      --exclude "*.html" \
      --exclude "service-worker.js"

    aws s3 cp ./build/index.html s3://${{ secrets.S3_BUCKET_NAME }}/index.html \
      --cache-control "no-cache"
```

## 필요한 시크릿

| 시크릿 | 설명 |
|--------|------|
| `AWS_ACCESS_KEY_ID` | AWS 액세스 키 |
| `AWS_SECRET_ACCESS_KEY` | AWS 시크릿 키 |
| `AWS_REGION` | AWS 리전 |
| `S3_BUCKET_NAME` | S3 버킷 이름 |

## 필요한 IAM 권한

```json
{
  "Effect": "Allow",
  "Action": [
    "s3:PutObject",
    "s3:GetObject",
    "s3:DeleteObject",
    "s3:ListBucket"
  ],
  "Resource": [
    "arn:aws:s3:::bucket-name/*",
    "arn:aws:s3:::bucket-name"
  ]
}
```
