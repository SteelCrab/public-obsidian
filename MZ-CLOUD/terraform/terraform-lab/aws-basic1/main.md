# Terraform main.tf 설정

#terraform #main #aws #ec2 #instance #vpc

---

`main.tf`는 실제 배포할 리소스를 정의하는 파일입니다.
`network.tf`에서 생성한 서브넷에 EC2 인스턴스를 배치합니다. → [[network]] | [[provider]]

## 파일 구조

```hcl
resource "aws_instance" "name" {
  ami                    = "ami-054240677cb44ffac"
  instance_type          = "t4g.micro"
  subnet_id              = aws_subnet.pista-subnet.id
  vpc_security_group_ids = [aws_security_group.pista-sg.id]

  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
    INSTANCE_NAME="pista-test-ec2"
    cat > /var/www/html/index.html <<HTML
    <h1>$INSTANCE_NAME</h1>
    <p>IP: $INSTANCE_IP</p>
    HTML
    systemctl enable nginx
    systemctl start nginx
  EOF

  tags = {
    Name = "pista-test-ec2"
  }
}
```

## resource 블록

| 항목 | 설명 |
|------|------|
| `ami` | 사용할 AMI ID (리전별로 다름) |
| `instance_type` | EC2 인스턴스 타입 |
| `subnet_id` | 배치할 서브넷 참조 (`aws_subnet.<name>.id`) |
| `vpc_security_group_ids` | 적용할 보안그룹 ID 목록 |
| `user_data` | 인스턴스 최초 부팅 시 실행할 스크립트 |
| `tags` | AWS 리소스에 붙이는 메타데이터 |

## user_data 스크립트

| 단계 | 설명 |
|------|------|
| `apt-get install nginx` | nginx 웹 서버 설치 |
| `curl 169.254.169.254` | EC2 메타데이터에서 Private IP 조회 |
| `index.html` 생성 | 인스턴스 Name, IP를 표시하는 웹 페이지 |
| `systemctl enable/start` | nginx 자동 시작 및 실행 |

> 배포 후 `http://<Public IP>` 접속하면 인스턴스 이름과 IP를 확인할 수 있습니다.

## root_block_device 블록

| 항목 | 설명 |
|------|------|
| `volume_size` | 루트 볼륨 크기 (GB) |
| `volume_type` | 볼륨 타입 (`gp3` = 범용 SSD 3세대) |
| `delete_on_termination` | `true` - EC2 삭제 시 볼륨 함께 삭제 |

### EBS 볼륨 타입 비교

| 타입 | 특징 | 용도 |
|------|------|------|
| `gp3` | 범용 SSD, 기본 3000 IOPS | 일반 서버 (권장) |
| `gp2` | 범용 SSD, IOPS가 용량에 비례 | 구형 범용 |
| `io1` | 고성능 SSD, IOPS 직접 지정 | DB 서버 |

### 주요 instance_type

| 타입 | 아키텍처 | vCPU | 메모리 | 용도 |
|------|----------|------|--------|------|
| `t4g.micro` | ARM64 (Graviton) | 2 | 1 GB | 테스트 / 프리티어 |
| `t4g.small` | ARM64 (Graviton) | 2 | 2 GB | 경량 서버 |
| `t3.micro` | x86_64 | 2 | 1 GB | 테스트 / 프리티어 |
| `t3.small` | x86_64 | 2 | 2 GB | 경량 서버 |

> AMI 아키텍처와 instance_type 아키텍처가 **반드시 일치**해야 합니다.

### AMI (ap-southeast-1 기준)

| OS | AMI ID | 아키텍처 |
|----|--------|----------|
| Ubuntu Server 24.04 LTS | `ami-054240677cb44ffac` | ARM64 |

## 리소스 의존 관계

```
provider.tf  →  network.tf (aws_vpc → aws_subnet)  →  main.tf (aws_instance)
```

> `subnet_id = aws_subnet.pista-subnet.id`로 `network.tf`의 서브넷을 참조합니다.
> Terraform이 자동으로 VPC → 서브넷 → EC2 순서로 생성합니다.

## 실행 방법

```bash
# 1. 초기화 (provider 플러그인 다운로드)
terraform init

# 2. 실행 계획 확인 (변경 사항 미리 보기)
terraform plan

# 3. 리소스 생성
terraform apply

# 4. 리소스 삭제
terraform destroy
```

| 명령어 | 설명 |
|--------|------|
| `terraform init` | provider 플러그인 설치, `.terraform/` 생성 |
| `terraform plan` | 생성/수정/삭제될 리소스 미리 확인 |
| `terraform apply` | 실제 리소스 배포 (`yes` 입력 필요) |
| `terraform destroy` | 모든 리소스 삭제 (`yes` 입력 필요) |

---

[Terraform MOC](../../Terraform_MOC.md)
