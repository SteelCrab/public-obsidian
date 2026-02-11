# GitHub Actions AWS 인증 설정

#github #actions #aws #credentials

---

AWS 서비스 사용을 위한 인증 설정.

## aws-actions/configure-aws-credentials

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ${{ secrets.AWS_REGION }}
```

## 옵션

| 옵션 | 설명 |
|------|------|
| `aws-access-key-id` | AWS 액세스 키 ID |
| `aws-secret-access-key` | AWS 시크릿 액세스 키 |
| `aws-region` | AWS 리전 (예: ap-northeast-2) |
| `role-to-assume` | IAM 역할 ARN (OIDC 사용 시) |

## 필요한 시크릿

| 시크릿 | 설명 |
|--------|------|
| `AWS_ACCESS_KEY_ID` | IAM 사용자 액세스 키 |
| `AWS_SECRET_ACCESS_KEY` | IAM 사용자 시크릿 키 |
| `AWS_REGION` | ap-northeast-2, us-east-1 등 |

## OIDC 사용 (권장)

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::123456789012:role/GitHubActionsRole
    aws-region: ap-northeast-2
```
