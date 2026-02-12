# GCP VM SSH 접속

#gcp #compute #ssh #iap

---

GCP VM에 SSH 접속하는 다양한 방법과 SCP 파일 전송, IAP 설정을 정리한 노트.

관련 문서: [[gcp-compute-engine]], [[gcp-vm-management]]

## gcloud SSH 접속

```bash
# 기본 SSH 접속
gcloud compute ssh web-server --zone=asia-northeast3-a

# 특정 사용자로 접속
gcloud compute ssh myuser@web-server --zone=asia-northeast3-a

# 커스텀 SSH 키 사용
gcloud compute ssh web-server \
    --zone=asia-northeast3-a \
    --ssh-key-file=~/.ssh/my-key

# IAP 터널링 사용 (외부 IP 없는 VM)
gcloud compute ssh web-server \
    --zone=asia-northeast3-a \
    --tunnel-through-iap

# SSH 명령어 직접 실행
gcloud compute ssh web-server \
    --zone=asia-northeast3-a \
    --command="sudo systemctl status nginx"
```

### SSH 터널링 (Local Port Forwarding)

로컬 PC의 포트를 통해 원격지(Private VM)의 서비스에 직접 접속할 때 사용합니다.

```bash
# 기본 문법: -L [로컬포트]:[원격지IP]:[원격지포트]
gcloud compute ssh [PUBLIC_VM_NAME] -- -L 8080:[PRIVATE_VM_IP]:80

# 예시: 로컬 8080 포트로 접속 시 Private VM(10.0.2.3)의 80 포트로 연결
gcloud compute ssh pista-public-nginx --zone=asia-northeast3-a -- -L 8080:10.0.2.3:80
```
- **접속 확인**: 브라우저에서 `http://localhost:8080` 입력 시 Private VM의 웹서버 페이지가 열립니다.

---

## SCP 파일 전송

```bash
# 로컬 -> VM
gcloud compute scp local-file.txt web-server:/tmp/ \
    --zone=asia-northeast3-a

# VM -> 로컬
gcloud compute scp web-server:/tmp/remote-file.txt ./ \
    --zone=asia-northeast3-a

# 디렉토리 전송 (재귀)
gcloud compute scp --recurse ./local-dir web-server:/tmp/ \
    --zone=asia-northeast3-a
```

---

## IAP (Identity-Aware Proxy) 설정

```bash
# IAP용 방화벽 규칙 생성
gcloud compute firewall-rules create allow-iap-ssh \
    --network=pista-vpc \
    --allow=tcp:22 \
    --source-ranges=35.235.240.0/20 \
    --description="Allow SSH from IAP"

# IAP 터널링으로 SSH 접속
gcloud compute ssh private-server \
    --zone=asia-northeast3-a \
    --tunnel-through-iap
```

### IAP 웹 콘솔

> 📍 보안 > Identity-Aware Proxy

1. **SSH 및 TCP 리소스** 탭 선택
2. 대상 VM 선택
3. 오른쪽 패널에서 **주 구성원 추가** 클릭
4. **새 주 구성원**: 사용자 이메일 입력
5. **역할**: `IAP 보안 터널 사용자` 선택
6. **저장** 클릭

### 브라우저 SSH 접속

> 📍 Compute Engine > VM 인스턴스

1. 대상 VM의 **SSH** 버튼 클릭
2. 브라우저에서 SSH 터미널 자동 열림
3. 외부 IP 없는 VM은 **SSH 옆 ▼** > **브라우저 창에서 열기 (IAP 사용)** 선택
