# GCP Cloud Storage 알림 및 이벤트

#gcp #storage #이벤트 #pubsub #알림

---

Cloud Storage 버킷의 Pub/Sub 알림 설정 및 이벤트 유형 정리.

## Pub/Sub 알림

```bash
# Pub/Sub 토픽 생성
gcloud pubsub topics create storage-notifications

# 버킷 알림 생성 (모든 이벤트)
gcloud storage buckets notifications create gs://my-bucket-name \
    --topic=storage-notifications

# 특정 이벤트만 알림
gcloud storage buckets notifications create gs://my-bucket-name \
    --topic=storage-notifications \
    --event-types=OBJECT_FINALIZE,OBJECT_DELETE

# 특정 접두사 필터
gcloud storage buckets notifications create gs://my-bucket-name \
    --topic=storage-notifications \
    --object-prefix=uploads/

# 알림 목록 확인
gcloud storage buckets notifications list gs://my-bucket-name

# 알림 삭제
gcloud storage buckets notifications delete gs://my-bucket-name/<notification-id>
```

## 이벤트 유형

| **이벤트** | **설명** |
|-----------|---------|
| `OBJECT_FINALIZE` | 객체 생성 완료 (업로드, 복사, 덮어쓰기) |
| `OBJECT_DELETE` | 객체 삭제 |
| `OBJECT_ARCHIVE` | 버전 관리에서 객체가 아카이브됨 |
| `OBJECT_METADATA_UPDATE` | 객체 메타데이터 변경 |

---

**관련 문서**: [[gcp-cloud-storage]]
