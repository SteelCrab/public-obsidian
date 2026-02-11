# GCP Cloud Storage 버전 관리 및 수명 주기

#gcp #storage #버전관리 #수명주기 #autoclass

---

Cloud Storage 객체 버전 관리, 수명 주기 규칙 설정, Autoclass 자동 전환 기능 정리.

## 버전 관리

### CLI (gcloud)

```bash
# 버전 관리 활성화
gcloud storage buckets update gs://my-bucket-name \
    --versioning

# 버전 관리 비활성화
gcloud storage buckets update gs://my-bucket-name \
    --no-versioning

# 모든 버전 목록 확인
gcloud storage ls --all-versions gs://my-bucket-name/

# 특정 버전 복원
gcloud storage cp gs://my-bucket-name/file.txt#<generation-number> \
    gs://my-bucket-name/file.txt

# 이전 버전 삭제
gcloud storage rm gs://my-bucket-name/file.txt#<generation-number>
```

### 웹 콘솔

> 📍 Cloud Storage > 버킷 > my-bucket-name > 보호

1. **객체 버전 관리** 섹션에서 `사용` 토글 활성화
2. 이전 버전은 **객체** 탭에서 파일 선택 > **버전 관리** 클릭으로 확인

---

## 수명 주기 관리 (Lifecycle)

### 수명 주기 규칙 JSON 예시

```json
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "SetStorageClass", "storageClass": "NEARLINE"},
        "condition": {"age": 30, "matchesStorageClass": ["STANDARD"]}
      },
      {
        "action": {"type": "SetStorageClass", "storageClass": "COLDLINE"},
        "condition": {"age": 90, "matchesStorageClass": ["NEARLINE"]}
      },
      {
        "action": {"type": "SetStorageClass", "storageClass": "ARCHIVE"},
        "condition": {"age": 365, "matchesStorageClass": ["COLDLINE"]}
      },
      {
        "action": {"type": "Delete"},
        "condition": {"age": 730}
      },
      {
        "action": {"type": "Delete"},
        "condition": {"isLive": false, "numNewerVersions": 3}
      }
    ]
  }
}
```

### 수명 주기 적용

#### CLI (gcloud)

```bash
# 수명 주기 규칙 적용
gcloud storage buckets update gs://my-bucket-name \
    --lifecycle-file=lifecycle.json

# 현재 수명 주기 확인
gcloud storage buckets describe gs://my-bucket-name \
    --format="json(lifecycle)"

# 수명 주기 제거
gcloud storage buckets update gs://my-bucket-name \
    --clear-lifecycle
```

#### 웹 콘솔

> 📍 Cloud Storage > 버킷 > my-bucket-name > 수명 주기

1. **규칙 추가** 클릭
2. **작업 선택**:
   - `스토리지 클래스를 다음으로 설정` > `Nearline` 선택
3. **조건 선택**:
   - **기간**: `30`일 입력
   - **스토리지 클래스가 일치**: `Standard` 선택
4. **만들기** 클릭
5. 추가 규칙도 같은 방식으로 생성 (Coldline 90일, Archive 365일, 삭제 730일)

---

## Autoclass (자동 클래스 전환)

```bash
# Autoclass 활성화 (Google이 접근 패턴에 따라 자동 전환)
gcloud storage buckets create gs://my-bucket-name \
    --location=asia-northeast1 \
    --enable-autoclass

# 기존 버킷에 Autoclass 활성화
gcloud storage buckets update gs://my-bucket-name \
    --enable-autoclass
```

---

**관련 문서**: [[gcp-cloud-storage]] | [[gcp-storage-bucket]]
