# GCP Cloud Storage 버킷 관리

#gcp #storage #버킷 #CLI

---

Cloud Storage 버킷 생성 및 관리 명령어 정리.

## 버킷 생성

### CLI (gcloud)

```bash
# 기본 버킷 생성 (리전)
gcloud storage buckets create gs://my-bucket-name \
    --location=asia-northeast1

# 상세 옵션 버킷 생성
gcloud storage buckets create gs://my-bucket-name \
    --location=asia-northeast1 \
    --default-storage-class=COLDLINE \
    --uniform-bucket-level-access \
    --public-access-prevention=enforced

# 멀티 리전 버킷
gcloud storage buckets create gs://my-bucket-name \
    --location=ASIA \
    --default-storage-class=COLDLINE

# 듀얼 리전 버킷
gcloud storage buckets create gs://my-bucket-name \
    --location=ASIA \
    --placement=asia-northeast1,asia-northeast3
```

### 웹 콘솔

> 📍 Cloud Storage > 버킷 > 만들기

1. **버킷 이름 지정**: `my-bucket-name` 입력 (전역 고유)
2. **데이터 저장 위치 선택**:
   - **위치 유형**: `Region` 선택
   - **위치**: `asia-northeast1 (도쿄)` 선택
3. **데이터의 스토리지 클래스 선택**: `Standard` 선택
4. **객체 액세스를 제어하는 방법 선택**:
   - **균일한 액세스 제어**: 체크 (권장)
   - **공개 액세스 방지**: 체크
5. **객체 데이터를 보호하는 방법 선택**: 기본값 유지
6. **만들기** 클릭

## 버킷 생성 옵션

| **옵션**                          | **설명**                 | **값**                                         |
| ------------------------------- | ---------------------- | --------------------------------------------- |
| `--location`                    | 버킷 위치                  | `asia-northeast1` (도쿄), `ASIA` (멀티 리전)        |
| `--default-storage-class`       | 기본 스토리지 클래스            | `STANDARD`, `NEARLINE`, `COLDLINE`, `ARCHIVE` |
| `--uniform-bucket-level-access` | 균일한 버킷 수준 접근 (IAM만 사용) | 플래그 설정 (권장)                                   |
| `--public-access-prevention`    | 공개 접근 방지               | `enforced` (차단), `inherited` (상속)             |
| `--enable-autoclass`            | 자동 스토리지 클래스 전환         | 플래그 설정                                        |
| `--soft-delete-duration`        | 소프트 삭제 보관 기간           | `7d` (기본), `0` (비활성화)                         |

## 버킷 관리

### CLI (gcloud)

```bash
# 버킷 목록
gcloud storage buckets list

# 버킷 상세 정보
gcloud storage buckets describe gs://my-bucket-name

# 버킷 설정 업데이트
gcloud storage buckets update gs://my-bucket-name \
    --default-storage-class=NEARLINE

# 버킷 삭제 (비어 있어야 함)
gcloud storage rm --recursive gs://my-bucket-name
```

### 웹 콘솔

> 📍 Cloud Storage > 버킷

- **목록 확인**: 버킷 목록 페이지에서 확인
- **상세 정보**: 버킷 이름 클릭 > **구성** 탭
- **설정 변경**: 버킷 이름 클릭 > **구성** 탭 > **수정**
- **삭제**: 버킷 체크박스 선택 > **삭제** 클릭

---

**관련 문서**: [[gcp-cloud-storage]] | [[gcp-storage-object]] | [[gcp-storage-iam]]
