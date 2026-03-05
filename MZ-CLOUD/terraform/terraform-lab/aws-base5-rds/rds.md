# Terraform rds.tf 설정 (aws-base5-rds)

#terraform #aws #rds #mysql #db서브넷그룹 #단일AZ

---

`rds.tf`는 RDS MySQL 인스턴스를 최소 구성으로 정의합니다.
`private-rds-a/b` 격리 서브넷에 배치되어 인터넷과 차단되고, 앱 서버 서브넷에서만 접근 가능합니다.

> 관련 문서: [[network]], [[bastion]]

## 리소스 목록

| 리소스 | Name | 설명 |
|--------|------|------|
| `variable` | `db_password` | RDS 마스터 패스워드 (sensitive) |
| `aws_db_subnet_group` | `pista-rds-subnet-group` | RDS 서브넷 그룹 (2개 AZ) |
| `aws_db_instance` | `pista-rds` | MySQL 8.0 단일 인스턴스 |

## aws_db_subnet_group 블록

| 항목 | 값 | 설명 |
|------|---|------|
| `subnet_ids` | `private-rds-a`, `private-rds-b` | 2개 AZ 필수 조건 충족 |

> DB Subnet Group은 최소 **2개 AZ** 서브넷을 포함해야 합니다.

## aws_db_instance 블록

| 항목 | 값 | 설명 |
|------|---|------|
| `engine` | `mysql` | 데이터베이스 엔진 |
| `engine_version` | `8.0` | MySQL 버전 |
| `instance_class` | `db.t3.micro` | 최소 인스턴스 타입 |
| `allocated_storage` | `20` (GB) | 기본 스토리지 |
| `storage_type` | `gp2` | 범용 SSD |
| `db_name` | `pistadb` | 기본 데이터베이스명 |
| `username` | `admin` | 마스터 사용자 |
| `password` | `var.db_password` | tfvars 또는 `-var` 로 입력 |
| `multi_az` | `false` | 단일 AZ (실습용) |
| `publicly_accessible` | `false` | 인터넷 비공개 |
| `skip_final_snapshot` | `true` | destroy 시 스냅샷 생략 |
| `backup_retention_period` | `0` | 자동 백업 비활성화 |

## 패스워드 입력 방법

```bash
# 방법 1: 실행 시 직접 입력
terraform apply -var="db_password=MyPassword123!"

# 방법 2: terraform.tfvars 파일 생성 (gitignore 추가 필수)
echo 'db_password = "MyPassword123!"' > terraform.tfvars
```

> `terraform.tfvars`는 반드시 `.gitignore`에 추가하세요.

## Output

| 출력값 | 설명 |
|--------|------|
| `rds_endpoint` | RDS 접속 엔드포인트 (host:port) |

## 접속 테스트 (Bastion 경유)

```bash
# 1. Bastion 접속
ssh -i ~/.ssh/pista-key ubuntu@$(terraform output -raw bastion_public_ip)

# 2. RDS 접속
mysql -h $(terraform output -raw rds_endpoint | cut -d: -f1) \
      -u admin -p pistadb
```

---

[Terraform MOC](../../Terraform_MOC.md)
