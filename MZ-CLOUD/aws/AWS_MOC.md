# AWS MOC

#aws #cli #cloud #MOC

---

AWS CLI 명령어와 서비스를 연결하는 허브 노트.

---

## 설정

- [[aws-configure]] - CLI 설정
- [[aws-profile]] - 프로파일 관리
- [[aws-sts]] - 자격 증명 확인

---

## 컴퓨팅

- [[aws-ec2]] - EC2 인스턴스
- [[aws-asg]] - Auto Scaling Group
- [[aws-lambda]] - Lambda 함수
- [[aws-ecs]] - ECS 컨테이너
- [[aws-eks]] - EKS Kubernetes

---

## 스토리지

- [[aws-s3]] - S3 버킷
- [[aws-ebs]] - EBS 볼륨

---

## 데이터베이스

- [[aws-rds]] - RDS
- [[aws-dynamodb]] - DynamoDB

---

## 네트워크

- [[aws-vpc]] - VPC
- [[aws-elb]] - 로드밸런서
- [[aws-route53]] - Route 53

---

## 보안

- [[aws-iam]] - IAM
- [[aws-secrets-manager]] - Secrets Manager
- [[aws-kms]] - KMS

---

## 모니터링

- [[aws-cloudwatch]] - CloudWatch
- [[aws-cloudtrail]] - CloudTrail
- [[aws-systemsmanager]] - Systems Manager

---

## 배포

- [[aws-ecr]] - ECR 레지스트리
- [[aws-codedeploy]] - CodeDeploy
- [[aws-cloudformation]] - CloudFormation

---

## 빠른 참조
![[aws-resource-2026-02-04-1]]

| 상황      | 명령어                           |
| ------- | ----------------------------- |
| 설정 확인   | `aws configure list`          |
| 계정 확인   | `aws sts get-caller-identity` |
| S3 목록   | `aws s3 ls`                   |
| EC2 목록  | `aws ec2 describe-instances`  |
| 리전 지정   | `--region ap-northeast-2`     |
| 프로파일 지정 | `--profile myprofile`         |
| JSON 출력 | `--output json`               |

---

## 외부 링크

- [AWS CLI 문서](https://docs.aws.amazon.com/cli/)
- [AWS CLI 명령어 레퍼런스](https://awscli.amazonaws.com/v2/documentation/api/latest/index.html)

---

*Zettelkasten 스타일로 구성됨*
