# Terraform bastion.tf 설정 (aws-base5-rds)

#terraform #aws #bastion #ec2 #키페어 #보안그룹

---

`bastion.tf`는 퍼블릭 서브넷에 배치되는 점프 서버(Bastion Host)를 정의합니다.
SSH 접근을 통해 프라이빗 서브넷의 앱 서버 및 RDS에 접근하는 경로입니다.

> 관련 문서: [[network]], [[rds]]

## 리소스 목록

| 리소스 | Name | 설명 |
|--------|------|------|
| `aws_key_pair` | `pista-key` | SSH 키페어 (`~/.ssh/pista-key.pub` 사용) |
| `aws_security_group` | `pista-bastion-sg` | SSH 22 인바운드 허용 |
| `aws_instance` | `pista-bastion` | 퍼블릭 서브넷 EC2 |

## aws_key_pair 블록

| 항목 | 값 | 설명 |
|------|---|------|
| `key_name` | `pista-key` | AWS 키페어 이름 |
| `public_key` | `file("~/.ssh/pista-key.pub")` | 로컬 공개키 파일 참조 |

> 사전 요건: `ssh-keygen -t rsa -b 4096 -f ~/.ssh/pista-key` 로 키 생성 필요

## aws_security_group 블록 (pista-bastion-sg)

| 방향 | 포트 | 소스 | 설명 |
|------|------|------|------|
| Inbound | 22 (TCP) | 0.0.0.0/0 | SSH 전체 허용 |
| Outbound | 전체 | 0.0.0.0/0 | 모든 아웃바운드 허용 |

## aws_instance 블록

| 항목 | 값 | 설명 |
|------|---|------|
| `ami` | `ami-054240677cb44ffac` | Ubuntu 22.04 ARM (ap-southeast-1) |
| `instance_type` | `t4g.micro` | ARM Graviton2 |
| `subnet_id` | `pista-public-a` | 퍼블릭 서브넷 배치 |
| `key_name` | `pista-key` | 키페어 참조 |
| `user_data` | `filebase64("bastion-init.sh")` | 초기화 스크립트 |

## bastion-init.sh 설치 목록

| 패키지 | 용도 |
|--------|------|
| `mysql-client` | RDS 접속 테스트 |
| `curl`, `wget` | 다운로드 도구 |
| `unzip`, `vim` | 기본 유틸리티 |
| AWS CLI v2 | AWS 리소스 관리 |

## Bastion 접속 방법

```bash
# SSH 접속
ssh -i ~/.ssh/pista-key ubuntu@<bastion_public_ip>

# Bastion 경유 RDS 접속
mysql -h <rds_endpoint> -u admin -p pistadb
```

## Output

| 출력값 | 설명 |
|--------|------|
| `bastion_public_ip` | Bastion 퍼블릭 IP (`terraform output bastion_public_ip`) |

---

[Terraform MOC](../../Terraform_MOC.md)
