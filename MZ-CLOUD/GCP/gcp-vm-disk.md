# GCP VM 디스크 관리

#gcp #compute #디스크 #스토리지

---

GCP Compute Engine VM의 디스크 유형, 생성, 연결, 크기 조정, 로컬 SSD를 정리한 노트.

관련 문서: [[gcp-compute-engine]], [[gcp-snapshot]]

## 디스크 유형

| **디스크 유형** | **IOPS/GB** | **처리량** | **용도** | **비용** |
|--------------|-----------|----------|---------|---------|
| `pd-standard` | 낮음 | 낮음 | 백업, 아카이브 | 가장 저렴 |
| `pd-balanced` | 중간 | 중간 | 일반 워크로드 (권장) | 중간 |
| `pd-ssd` | 높음 | 높음 | 데이터베이스, 고성능 앱 | 비싸다 |
| `pd-extreme` | 매우 높음 | 매우 높음 | SAP HANA, Oracle | 가장 비싸다 |
| `local-ssd` | 최고 | 최고 | 임시 데이터, 캐시 | vCPU당 요금 |

---

## 영구 디스크 생성 및 연결

### CLI (gcloud)

```bash
# 영구 디스크 생성
gcloud compute disks create data-disk \
    --size=100GB \
    --type=pd-balanced \
    --zone=asia-northeast1-a

# 기존 VM에 디스크 연결
gcloud compute instances attach-disk web-server \
    --disk=data-disk \
    --zone=asia-northeast1-a

# VM 내부에서 디스크 포맷 및 마운트
# SSH로 접속 후:
sudo mkfs.ext4 -F /dev/sdb
sudo mkdir -p /mnt/data
sudo mount /dev/sdb /mnt/data
echo '/dev/sdb /mnt/data ext4 defaults 0 0' | sudo tee -a /etc/fstab

# 디스크 분리
gcloud compute instances detach-disk web-server \
    --disk=data-disk \
    --zone=asia-northeast1-a
```

### 웹 콘솔

> 📍 Compute Engine > 디스크 > 디스크 만들기

**디스크 생성:**
1. **이름**: `data-disk` 입력
2. **리전**: `asia-northeast1` 선택
3. **영역**: `asia-northeast1-a` 선택
4. **디스크 유형**: `균형 있는 영구 디스크` 선택
5. **크기**: `100` GB 입력
6. **만들기** 클릭

**디스크 연결:**
> 📍 Compute Engine > VM 인스턴스 > web-server > 수정

1. **추가 디스크** > **기존 디스크 연결** 클릭
2. **디스크**: `data-disk` 선택
3. **저장** 클릭

---

## 디스크 크기 조정 (확장만 가능)

### CLI (gcloud)

```bash
# 디스크 크기 확장 (100GB -> 200GB)
gcloud compute disks resize data-disk \
    --size=200GB \
    --zone=asia-northeast1-a

# VM 내부에서 파일시스템 확장
sudo resize2fs /dev/sdb
```

### 웹 콘솔

> 📍 Compute Engine > 디스크 > data-disk > 수정

1. **크기**: `200` GB로 변경
2. **저장** 클릭

> VM 내부에서 `sudo resize2fs /dev/sdb` 실행 필요

---

## 로컬 SSD 추가

```bash
# VM 생성 시 로컬 SSD 추가 (최대 24개, 각 375GB)
gcloud compute instances create vm-with-ssd \
    --zone=asia-northeast1-a \
    --machine-type=n2-standard-4 \
    --local-ssd=interface=NVME \
    --local-ssd=interface=NVME
```
