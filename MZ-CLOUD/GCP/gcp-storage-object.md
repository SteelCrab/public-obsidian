# GCP Cloud Storage 객체 관리

#gcp #storage #객체 #CLI #gsutil

---

Cloud Storage 객체 업로드, 다운로드, 관리, 동기화 명령어 및 gsutil과 gcloud storage 비교.

## 업로드

```bash
# 단일 파일 업로드
gcloud storage cp local-file.txt gs://my-bucket-name/

# 디렉토리 업로드 (재귀)
gcloud storage cp --recursive ./local-dir gs://my-bucket-name/path/

# 스토리지 클래스 지정 업로드
gcloud storage cp local-file.txt gs://my-bucket-name/ \
    --storage-class=NEARLINE

# 병렬 업로드 (대용량 파일)
gcloud storage cp large-file.zip gs://my-bucket-name/ \
    --parallel-composite-upload-enabled
```

## 다운로드

```bash
# 단일 파일 다운로드
gcloud storage cp gs://my-bucket-name/file.txt ./

# 디렉토리 다운로드
gcloud storage cp --recursive gs://my-bucket-name/path/ ./local-dir/
```

## 객체 관리

```bash
# 객체 목록
gcloud storage ls gs://my-bucket-name/
gcloud storage ls --recursive gs://my-bucket-name/

# 객체 상세 정보
gcloud storage objects describe gs://my-bucket-name/file.txt

# 객체 이동/이름 변경
gcloud storage mv gs://my-bucket-name/old-name.txt gs://my-bucket-name/new-name.txt

# 버킷 간 복사
gcloud storage cp gs://source-bucket/file.txt gs://dest-bucket/

# 객체 삭제
gcloud storage rm gs://my-bucket-name/file.txt

# 디렉토리 삭제 (재귀)
gcloud storage rm --recursive gs://my-bucket-name/path/
```

## 동기화 (rsync)

```bash
# 로컬 → 버킷 동기화
gcloud storage rsync ./local-dir gs://my-bucket-name/path/ --recursive

# 버킷 → 로컬 동기화
gcloud storage rsync gs://my-bucket-name/path/ ./local-dir --recursive

# 삭제 동기화 포함 (소스에 없는 파일은 대상에서 삭제)
gcloud storage rsync ./local-dir gs://my-bucket-name/path/ \
    --recursive --delete-unmatched-destination-objects
```

---

## gsutil vs gcloud storage

| **항목** | **gsutil** | **gcloud storage** |
|---------|-----------|-------------------|
| **상태** | 레거시 (유지보수 모드) | 권장 (신규 기능 추가) |
| **성능** | 보통 | 더 빠름 (병렬 처리 개선) |
| **명령어 예시** | `gsutil cp`, `gsutil ls` | `gcloud storage cp`, `gcloud storage ls` |
| **설치** | Cloud SDK에 포함 | Cloud SDK에 포함 |

### 명령어 대응 표

```bash
# gsutil → gcloud storage 대응
# gsutil ls          → gcloud storage ls
# gsutil cp          → gcloud storage cp
# gsutil mv          → gcloud storage mv
# gsutil rm          → gcloud storage rm
# gsutil rsync       → gcloud storage rsync
# gsutil mb          → gcloud storage buckets create
# gsutil rb          → gcloud storage rm --recursive
# gsutil iam         → gcloud storage buckets add-iam-policy-binding
```

---

**관련 문서**: [[gcp-cloud-storage]] | [[gcp-storage-bucket]]
