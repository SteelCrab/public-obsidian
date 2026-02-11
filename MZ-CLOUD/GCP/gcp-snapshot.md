# GCP 스냅샷 및 이미지

#gcp #compute #스냅샷 #이미지 #백업

---

GCP 디스크 스냅샷과 커스텀 이미지의 생성, 복원, 관리 방법을 정리한 노트.

관련 문서: [[gcp-compute-engine]], [[gcp-vm-disk]]

## 디스크 스냅샷

```bash
# 스냅샷 생성 (증분 백업)
gcloud compute disks snapshot web-server-boot \
    --zone=asia-northeast1-a \
    --snapshot-names=web-server-snapshot-$(date +%Y%m%d)

# 스냅샷 목록
gcloud compute snapshots list

# 스냅샷에서 디스크 복원
gcloud compute disks create restored-disk \
    --source-snapshot=web-server-snapshot-20260210 \
    --zone=asia-northeast1-a

# 스냅샷 삭제
gcloud compute snapshots delete web-server-snapshot-20260210
```

### 웹 콘솔

> 📍 Compute Engine > 스냅샷 > 스냅샷 만들기

1. **이름**: `web-server-snapshot-20260210` 입력
2. **소스 디스크**: `web-server-boot` 선택
3. **위치**: `리전` 또는 `멀티 리전` 선택
4. **만들기** 클릭

**스냅샷에서 디스크 복원:**
> 📍 Compute Engine > 디스크 > 디스크 만들기

1. **이름**: `restored-disk` 입력
2. **소스 유형**: `스냅샷` 선택
3. **소스 스냅샷**: `web-server-snapshot-20260210` 선택
4. **만들기** 클릭

---

## 커스텀 이미지

```bash
# 실행 중인 VM에서 이미지 생성
gcloud compute images create web-server-image-v1 \
    --source-disk=web-server-boot \
    --source-disk-zone=asia-northeast1-a \
    --family=web-server-images

# 이미지 목록
gcloud compute images list --no-standard-images

# 커스텀 이미지로 VM 생성
gcloud compute instances create web-server-clone \
    --zone=asia-northeast1-a \
    --image=web-server-image-v1

# 이미지 삭제
gcloud compute images delete web-server-image-v1
```

### 웹 콘솔

> 📍 Compute Engine > 이미지 > 이미지 만들기

1. **이름**: `web-server-image-v1` 입력
2. **소스**: `디스크` 선택
3. **소스 디스크**: `web-server-boot` 선택
4. **위치**: `멀티 리전` 또는 `리전` 선택
5. **패밀리**: `web-server-images` 입력 (선택 사항)
6. **만들기** 클릭

**커스텀 이미지로 VM 생성:**
> 📍 Compute Engine > VM 인스턴스 > 인스턴스 만들기

1. **부팅 디스크** > 변경 > **커스텀 이미지** 탭
2. **이미지**: `web-server-image-v1` 선택
3. 나머지 설정 후 **만들기** 클릭
