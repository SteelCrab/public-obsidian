# GitHub Actions SSM 배포

#github #actions #ssm #aws #ec2 #deploy

---

AWS Systems Manager로 EC2 배포.

## aws ssm send-command

```yaml
- name: Deploy via SSM
  run: |
    aws ssm send-command \
      --instance-ids "${{ secrets.EC2_INSTANCE_ID }}" \
      --document-name "AWS-RunShellScript" \
      --comment "Deploy application" \
      --parameters '{"commands":["echo Hello"]}' \
      --region ${{ secrets.AWS_REGION }}
```

## Docker 배포 예시

```yaml
- name: Deploy to EC2 via SSM
  env:
    ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
    ECR_REPOSITORY: my-app
    IMAGE_TAG: ${{ github.sha }}
  run: |
    aws ssm send-command \
      --instance-ids "${{ secrets.EC2_INSTANCE_ID }}" \
      --document-name "AWS-RunShellScript" \
      --comment "Deploy from ECR" \
      --parameters '{
        "commands": [
          "aws ecr get-login-password --region ${{ secrets.AWS_REGION }} | sudo docker login --username AWS --password-stdin '"$ECR_REGISTRY"'",
          "sudo docker pull '"$ECR_REGISTRY"'/'"$ECR_REPOSITORY"':'"$IMAGE_TAG"'",
          "sudo docker stop app || true",
          "sudo docker rm app || true",
          "sudo docker run -d --name app -p 8000:8000 '"$ECR_REGISTRY"'/'"$ECR_REPOSITORY"':'"$IMAGE_TAG"'",
          "sudo docker image prune -f"
        ]
      }' \
      --region ${{ secrets.AWS_REGION }}
```

## 필요한 시크릿

| 시크릿 | 설명 |
|--------|------|
| `EC2_INSTANCE_ID` | EC2 인스턴스 ID (i-xxxxx) |
| `AWS_REGION` | AWS 리전 |

## 필요한 IAM 권한

```json
{
  "Effect": "Allow",
  "Action": [
    "ssm:SendCommand",
    "ssm:GetCommandInvocation"
  ],
  "Resource": "*"
}
```

## EC2 인스턴스 요구사항

- SSM Agent 설치 및 실행 중
- IAM 역할에 `AmazonSSMManagedInstanceCore` 정책 연결
- 아웃바운드 HTTPS(443) 허용
