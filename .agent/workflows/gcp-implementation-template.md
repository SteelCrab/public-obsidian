---
description: GCP 구현 문서를 구조화된 템플릿 형식으로 작성 (네트워크, VM, 스크립트 포함)
---

// turbo-all

1. Create a new markdown file named `[YYYY-MM-DD].md` in the current directory (or use the existing daily note).
2. Populate the file with the following template structure, replacing placeholders with actual content based on the user's task.

---

# [Project/Task Name] ([YYYY-MM-DD])

#gcp #network #vm

```table-of-contents
```

---

## 1. 네트워크 인프라 구성 (VPC, NAT, Firewall)

[Description of network setup]

### 아키텍처

```
[VPC Name] (Custom Mode)
├── [Public Subnet Name]  ([CIDR])
├── [Private Subnet Name] ([CIDR])
├── [Router Name]
│   └── [NAT Name] (Auto Allocate IP)
└── Firewall Rules
    ├── allow-ssh (0.0.0.0/0)
    ├── allow-http (0.0.0.0/0)
    └── allow-internal ([CIDR])
```

### 플레이스홀더

| 변수 | 설명 | 예시 |
|------|------|------|
| `VPC_NAME` | VPC 이름 | `my-vpc` |
| `PUBLIC_SUBNET` | Public 서브넷 이름 | `my-public-subnet` |
| `PRIVATE_SUBNET` | Private 서브넷 이름 | `my-private-subnet` |
| `REGION` | 리전 | `asia-northeast3` |

### 구현 프로세스

| 단계 | 작업 | 상세 내용 |
| :--- | :--- | :--- |
| **1** | **VPC 생성** | Custom Mode, Regional Routing |
| **2** | **서브넷 생성** | Public/Private Subnet |
| **3** | **Router/NAT** | Cloud NAT 설정 |
| **4** | **방화벽 규칙** | SSH, HTTP, Internal 허용 |

**1단계: VPC 생성**

[Description]

```bash
# Command
```

**2단계: 서브넷 생성**

[Description]

```bash
# Command
```

---

## 2. VM 인스턴스 구성 (Public + Private)

[Description of VM setup]

### 아키텍처

```
[VPC Name]
├── [Public Subnet]
│   └── [Public VM] (External IP, Bastion)
└── [Private Subnet]
    └── [Private VM] (Internal IP Only)
```

### 구현 프로세스

| 단계 | 작업 | 상세 내용 |
| :--- | :--- | :--- |
| **1** | **스크립트 실행** | `bash [script_name].sh` |
| **2** | **접속 테스트** | Public IP 확인, Private IP 내부 통신 확인 |

**1단계: 스크립트 실행**

```bash
# OS: [Ubuntu Minimal 24.04 LTS]
bash [script_name].sh
```

**2단계: 접속 테스트**

1. **Public VM**: `http://<PUBLIC_IP>`
2. **Private VM**: 외부 IP가 없으므로 Public VM을 경유하거나 SSH 터널링을 사용해야 합니다.

### 🔌 Private VM 접속 가이드

**방법 1: Bastion 경유 (기본)**
```bash
# 1. Public VM 접속
gcloud compute ssh [Public VM] --zone=[Zone]

# 2. 내부에서 Private VM 호출
curl http://[Private IP]
```

**방법 2: SSH 터널링 (Local Port Forwarding)**
내 PC(Mac)의 로컬 포트를 통해 Private VM의 80 포트에 직접 접속합니다.

```bash
# 로컬 8080 포트 -> Private VM 80 포트 연결
gcloud compute ssh [Public VM] --zone=[Zone] -- -L 8080:[Private IP]:80
```
- **확인**: 브라우저에서 `http://localhost:8080` 접속

---

## 3. 구축 스크립트

| 스크립트 | 용도 | 실행 |
|---------|------|------|
| `[script_name].sh` | [Description] | `bash [script_name].sh` |

---

## 관련 노트
- [[GCP_MOC]]
- [[gcp-vm-ssh]] - SSH 상세 접속 가이드
