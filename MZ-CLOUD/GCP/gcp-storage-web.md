# GCP Cloud Storage 정적 웹사이트 호스팅

#gcp #storage #웹호스팅 #정적사이트

---

Cloud Storage를 사용한 정적 웹사이트 호스팅 설정 방법.

## 정적 웹사이트 호스팅

```bash
# 1. 버킷 생성
gcloud storage buckets create gs://www.example.com \
    --location=asia-northeast1

# 2. 공개 접근 허용
gcloud storage buckets add-iam-policy-binding gs://www.example.com \
    --member=allUsers \
    --role=roles/storage.objectViewer

# 3. 웹사이트 설정
gcloud storage buckets update gs://www.example.com \
    --web-main-page-suffix=index.html \
    --web-not-found-page=404.html

# 4. 파일 업로드
gcloud storage cp --recursive ./website/ gs://www.example.com/

# 접속: http://storage.googleapis.com/www.example.com/index.html
```

> HTTPS + 커스텀 도메인을 사용하려면 Cloud Load Balancer가 필요하다.

---

**관련 문서**: [[gcp-cloud-storage]] | [[gcp-storage-iam]] | [[gcp-load-balancer]]
