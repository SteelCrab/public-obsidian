# Terraform compute.tf 설정 (aws-base1-2)

#terraform #compute #aws #ec2 #instance #private-subnet #ebs

---

`compute.tf`는 EC2 인스턴스를 **Private Subnet**에 배치하는 파일입니다.
`network.tf`에서 생성한 Private 서브넷과 보안그룹을 참조합니다. → [[network]] | [[variables]]

## 파일 구조

```hcl
resource "aws_instance" "main" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.ec2.id]

  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = { Name = local.service_name }
}
```

## resource 블록

| 항목 | 값 | 설명 |
|------|-----|------|
| `ami` | `var.ami` | 변수로 AMI ID 주입 (Ubuntu 24.04 LTS x86) |
| `instance_type` | `var.instance_type` | 변수로 인스턴스 타입 주입 (기본: `t3.micro`) |
| `subnet_id` | `aws_subnet.private.id` | **Private Subnet**에 배치 |
| `vpc_security_group_ids` | `[aws_security_group.ec2.id]` | EC2 보안그룹 적용 |
| `tags` | `{ Name = local.service_name }` | `pista-worker-ec2` |

> aws-basic1과 차이: `subnet_id`가 `aws_subnet.pista-subnet.id`(Public) →  `aws_subnet.private.id`(Private)로 변경됩니다.

## root_block_device 블록

| 항목 | 값 | 설명 |
|------|-----|------|
| `volume_size` | `10` | 루트 볼륨 크기 (GB) |
| `volume_type` | `gp3` | 범용 SSD 3세대 |
| `delete_on_termination` | `true` | EC2 삭제 시 볼륨 함께 삭제 |

### EBS 볼륨 타입 비교

| 타입 | 특징 | 용도 |
|------|------|------|
| `gp3` | 범용 SSD, 기본 3000 IOPS | 일반 서버 (권장) |
| `gp2` | 범용 SSD, IOPS가 용량에 비례 | 구형 범용 |
| `io1` | 고성능 SSD, IOPS 직접 지정 | DB 서버 |

### 주요 instance_type

| 타입 | 아키텍처 | vCPU | 메모리 | 용도 |
|------|----------|------|--------|------|
| `t3.micro` | x86_64 | 2 | 1 GB | 테스트 / 프리티어 (기본값) |
| `t3.small` | x86_64 | 2 | 2 GB | 경량 서버 |
| `t4g.micro` | ARM64 (Graviton) | 2 | 1 GB | 비용 최적화 |
| `t4g.small` | ARM64 (Graviton) | 2 | 2 GB | 비용 최적화 경량 |

> AMI 아키텍처와 instance_type 아키텍처가 **반드시 일치**해야 합니다.

### AMI (ap-southeast-1 기준)

| OS | AMI ID | 아키텍처 |
|----|--------|----------|
| Ubuntu Server 24.04 LTS | `ami-08d59269edddde222` | x86_64 |
| Ubuntu Server 24.04 LTS | `ami-054240677cb44ffac` | ARM64 |

## user_data 참고 (aws-basic1 패턴)

현재 `compute.tf`에는 `user_data`가 없습니다. 필요 시 아래 패턴을 참고하세요.

```hcl
user_data = <<-EOF
  #!/bin/bash
  apt-get update -y
  apt-get install -y nginx
  INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
  INSTANCE_NAME="${local.service_name}"
  cat > /var/www/html/index.html <<HTML
  <h1>$INSTANCE_NAME</h1>
  <p>IP: $INSTANCE_IP</p>
  HTML
  systemctl enable nginx
  systemctl start nginx
EOF
```

| 단계 | 설명 |
|------|------|
| `apt-get install nginx` | nginx 웹 서버 설치 |
| `curl 169.254.169.254` | EC2 메타데이터에서 Private IP 조회 |
| `index.html` 생성 | 인스턴스 Name, IP를 표시하는 웹 페이지 |
| `systemctl enable/start` | nginx 자동 시작 및 실행 |

> Private Subnet 배치이므로 Public IP가 없습니다. 접근하려면 Bastion Host 또는 SSM Session Manager를 사용하세요.

## 리소스 의존 관계

```
provider.tf  →  variables.tf + locals.tf
                      ↓
               network.tf (aws_vpc → aws_subnet.private, aws_security_group)
                      ↓
               compute.tf (aws_instance)
```

## 실행 방법

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

---

[Terraform MOC](../../Terraform_MOC.md)
