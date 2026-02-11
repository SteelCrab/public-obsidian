# GCP VM 비용 최적화

#gcp #compute #비용 #최적화

---

GCP VM의 비용 절감 방법인 선점형 VM, Spot VM, 약정 사용 할인, 지속 사용 할인, VM 크기 조정을 정리한 노트.

관련 문서: [[gcp-compute-engine]], [[gcp-instance-template]]

## 선점형 VM (Preemptible VM)

```bash
# 선점형 VM 생성 (일반 VM 대비 60-91% 저렴)
gcloud compute instances create preemptible-vm \
    --zone=asia-northeast1-a \
    --machine-type=n2-standard-4 \
    --preemptible

# 주의사항:
# - 최대 24시간 실행
# - Google이 필요 시 언제든 종료 가능
# - SLA 없음
# - 배치 작업, 테스트 환경에 적합
```

---

## Spot VM (개선된 선점형 VM)

```bash
# Spot VM 생성
gcloud compute instances create spot-vm \
    --zone=asia-northeast1-a \
    --machine-type=n2-standard-4 \
    --provisioning-model=SPOT \
    --instance-termination-action=STOP

# Spot VM 특징:
# - 선점형 VM과 동일한 가격
# - 24시간 제한 없음
# - 종료 시 동작 선택 가능 (STOP, DELETE)
```

### 웹 콘솔

> 📍 Compute Engine > VM 인스턴스 > 인스턴스 만들기

1. **머신 구성** 설정
2. **가용성 정책** 섹션:
   - **VM 프로비저닝 모델**: `스팟` 선택
   - **인스턴스 종료 작업**: `중지` 또는 `삭제` 선택
3. **만들기** 클릭

---

## 약정 사용 할인 (CUD - Committed Use Discounts)

```bash
# 약정 구매 (1년 또는 3년)
gcloud compute commitments create my-commitment \
    --region=asia-northeast1 \
    --plan=12-month \
    --resources=vcpu=100,memory=400GB

# 약정 목록 확인
gcloud compute commitments list
```

---

## 지속 사용 할인 (자동 적용)

- 매월 특정 리소스를 25% 이상 사용 시 자동 할인
- 별도 설정 불필요
- 최대 30% 할인

---

## VM 크기 조정 (Resize)

```bash
# VM 중지 후 머신 타입 변경
gcloud compute instances stop web-server --zone=asia-northeast1-a

gcloud compute instances set-machine-type web-server \
    --zone=asia-northeast1-a \
    --machine-type=n2-standard-8

gcloud compute instances start web-server --zone=asia-northeast1-a
```

### 웹 콘솔

> 📍 Compute Engine > VM 인스턴스 > web-server

1. VM이 **실행 중**이면 상단의 **중지** 클릭
2. VM 중지 확인 후 **수정** 클릭
3. **머신 유형**: `n2-standard-8` 선택
4. **저장** 클릭
5. 상단의 **시작** 클릭
