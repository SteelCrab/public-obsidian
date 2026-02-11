# GCP Cloud Storage 접근 제어

#gcp #storage #iam #접근제어 #조직정책

---

Cloud Storage의 조직 정책 해제, IAM 접근 제어, 공개 접근 설정, 서명된 URL 관리.

## 조직 정책 해제

조직(Organization)에 공개 접근 방지 정책이 적용되어 있으면 버킷을 공개로 설정할 수 없다. 정적 웹 호스팅 등 공개 접근이 필요한 경우 조직 정책을 해제해야 한다.

### 조직 정책 확인

```bash
# 현재 조직 정책 확인
gcloud org-policies describe constraints/storage.publicAccessPrevention \
    --project=<PROJECT_ID>

# 조직 수준 정책 확인
gcloud org-policies describe constraints/storage.publicAccessPrevention \
    --organization=<ORG_ID>

# 프로젝트의 유효 정책 확인 (상속 포함)
gcloud org-policies describe constraints/storage.publicAccessPrevention \
    --project=<PROJECT_ID> --effective
```

### 프로젝트 수준에서 정책 해제

```bash
# 공개 접근 방지 정책 해제 (프로젝트 수준)
gcloud org-policies delete constraints/storage.publicAccessPrevention \
    --project=<PROJECT_ID>

# 또는 정책을 명시적으로 허용으로 설정
gcloud org-policies set-policy --project=<PROJECT_ID> policy.yaml
```

#### policy.yaml 예시

```yaml
name: projects/<PROJECT_ID>/policies/storage.publicAccessPrevention
spec:
  rules:
    - enforce: false
```

### 조직 정책 해제 - 웹 콘솔

> 📍 IAM 및 관리자 > 조직 정책

1. **필터**에서 `storage.publicAccessPrevention` 검색
2. 해당 정책 클릭
3. **정책 관리** 클릭
4. **규칙 추가** > **적용**: `해제` 선택
5. **정책 설정** 클릭

> 또는 📍 Cloud Storage > 버킷 > 버킷 선택 > **권한** 탭에서 공개 액세스 관련 설정 변경 가능

### 주요 Storage 관련 조직 정책

| **정책 제약조건** | **설명** | **기본값** |
|-----------------|---------|-----------|
| `storage.publicAccessPrevention` | 버킷/객체 공개 접근 방지 | 조직에 따라 다름 |
| `storage.uniformBucketLevelAccess` | 균일한 버킷 수준 접근 강제 | 미적용 |
| `storage.retentionPolicySeconds` | 최소 보존 기간 강제 | 미적용 |
| `iam.allowedPolicyMemberDomains` | 허용된 도메인만 IAM 멤버 추가 가능 | 조직에 따라 다름 |

### 버킷 수준에서 공개 접근 허용

```bash
# 조직 정책 해제 후, 버킷의 공개 접근 방지도 해제해야 함
gcloud storage buckets update gs://my-bucket-name \
    --no-public-access-prevention

# 이후 공개 IAM 바인딩 추가 가능
gcloud storage buckets add-iam-policy-binding gs://my-bucket-name \
    --member=allUsers \
    --role=roles/storage.objectViewer
```

> 프로덕션 환경에서는 조직 정책 해제를 최소 범위(프로젝트 또는 버킷 단위)로 제한하고, 필요한 버킷에만 공개 접근을 허용하는 것을 권장한다.

---

## IAM 정책 (Uniform Bucket-Level Access)

```bash
# 버킷에 IAM 역할 부여
gcloud storage buckets add-iam-policy-binding gs://my-bucket-name \
    --member=user:user@example.com \
    --role=roles/storage.objectViewer

# 서비스 계정에 역할 부여
gcloud storage buckets add-iam-policy-binding gs://my-bucket-name \
    --member=serviceAccount:sa@project-id.iam.gserviceaccount.com \
    --role=roles/storage.objectAdmin

# IAM 정책 확인
gcloud storage buckets get-iam-policy gs://my-bucket-name

# IAM 역할 제거
gcloud storage buckets remove-iam-policy-binding gs://my-bucket-name \
    --member=user:user@example.com \
    --role=roles/storage.objectViewer
```

### IAM 정책 - 웹 콘솔

> 📍 Cloud Storage > 버킷 > my-bucket-name > 권한

**IAM 역할 부여:**
1. **액세스 권한 부여** 클릭
2. **새 주 구성원**: `user@example.com` 입력
3. **역할 선택**: `Storage 객체 뷰어` 선택
4. **저장** 클릭

**역할 제거:**
1. 해당 주 구성원의 연필 아이콘 클릭
2. 역할 옆 삭제(🗑️) 아이콘 클릭
3. **저장** 클릭

### 주요 Storage IAM 역할

| **역할** | **설명** |
|---------|---------|
| `roles/storage.admin` | 버킷 및 객체 전체 관리 |
| `roles/storage.objectAdmin` | 객체 생성, 삭제, 조회 (버킷 관리 제외) |
| `roles/storage.objectCreator` | 객체 생성만 가능 |
| `roles/storage.objectViewer` | 객체 조회만 가능 |
| `roles/storage.legacyBucketOwner` | 레거시 버킷 소유자 (ACL 호환) |

## 공개 접근 설정 (주의)

```bash
# 버킷 전체 공개 읽기 (비권장)
gcloud storage buckets add-iam-policy-binding gs://my-bucket-name \
    --member=allUsers \
    --role=roles/storage.objectViewer

# 공개 접근 방지 활성화 (권장)
gcloud storage buckets update gs://my-bucket-name \
    --public-access-prevention=enforced
```

### 공개 접근 - 웹 콘솔

> 📍 Cloud Storage > 버킷 > my-bucket-name > 권한

**버킷 공개 설정:**
1. **공개 액세스** 섹션에서 `공개 액세스 방지 삭제` 클릭 (조직 정책 해제 후)
2. **액세스 권한 부여** 클릭
3. **새 주 구성원**: `allUsers` 입력
4. **역할**: `Storage 객체 뷰어` 선택
5. **저장** > **공개 액세스 허용** 확인

## 서명된 URL (임시 접근)

```bash
# 서명된 URL 생성 (1시간 유효)
gcloud storage sign-url gs://my-bucket-name/file.txt \
    --duration=1h \
    --private-key-file=service-account-key.json
```

---

**관련 문서**: [[gcp-cloud-storage]] | [[gcp-storage-bucket]] | [[gcp-storage-web]]
