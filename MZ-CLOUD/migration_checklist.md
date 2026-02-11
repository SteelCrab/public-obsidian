# pista-megazoncloud → MZ-CLOUD 마이그레이션 체크리스트

> **출발지**: `pista-megazoncloud` → **목적지**: `MZ-CLOUD`
> **핵심**: day-based 콘텐츠를 MOC(Map of Content) 형식으로 재구성
> **작성일**: 2026-02-11

---

## Phase 1: 사전 준비

- [x] **1.1** `MZ-CLOUD` 백업 (`MZ-CLOUD.bak`) ✅
- [x] **1.2** `.DS_Store` 제외 확인 ✅
- [x] **1.3** MOC 패턴 분석 완료 (Docker_MOC, Kubectl_MOC, Git_MOC) ✅
- [x] **1.4** 소스 디렉토리 콘텐츠 분석 완료 ✅

---

## Phase 2: 그룹 A — `database/` (이미 토픽 기반) ✅

- [x] **2.1** `pista/database/` → `MZ-CLOUD/database/` 복사 (47파일) ✅
- [x] **2.2** `README.md` → `Database_MOC.md`로 이름 변경 ✅
- [x] **2.3** `Database_MOC.md` MOC 형식으로 재작성 (wikilink 연결) ✅

---

## Phase 3: 그룹 B — day-based → MOC 재구성 ✅

### 3.1 `on-premise-ict/` ✅

- [x] **3.1.1** `pista/on-premise-ict/` → `MZ-CLOUD/on-premise-ict/` 복사 (77파일) ✅
- [x] **3.1.2** `README.md` → `OnPremise_MOC.md`로 이름 변경 ✅
- [x] **3.1.3** MOC 형식으로 재작성 (CI/CD, 아키텍처, 인프라 섹션) ✅

### 3.2 `personal-project/` ✅

- [x] **3.2.1** `pista/personal-project/` → `MZ-CLOUD/personal-project/` 복사 (61파일) ✅
- [x] **3.2.2** `REAMDE.md` → `PersonalProject_MOC.md`로 이름 변경 ✅
- [x] **3.2.3** MOC 형식으로 재작성 (인프라, K8s, InnoDB 섹션) ✅

### 3.3 `linux/` ✅

- [x] **3.3.1** `pista/linux/` → `MZ-CLOUD/linux/` 복사 (4파일) ✅
- [x] **3.3.2** `Linux_MOC.md` 신규 생성 ✅

### 3.4 `python/` ✅

- [x] **3.4.1** `pista/python/` → `MZ-CLOUD/python/` 복사 (2파일) ✅
- [x] **3.4.2** `README.md` → `Python_MOC.md`로 이름 변경 ✅
- [x] **3.4.3** MOC 형식으로 재작성 (기초문법, 제어문, 응용 섹션) ✅

---

## Phase 4: 그룹 C — 기존 MOC에 학습 기록 병합 ✅

### 4.1 `docker/` 병합 ✅

- [x] **4.1.1** day1-1126 ~ day6-1203 + public/ → `MZ-CLOUD/docker/` 병합 ✅
- [x] **4.1.2** `README.md` → `docker-learning-log.md`로 복사 ✅
- [x] **4.1.3** `Docker_MOC.md`에 "학습 기록" 섹션 추가 ✅

### 4.2 `kubernetes/` 병합 ✅

- [x] **4.2.1** day1-1204 ~ day7-1212 → `MZ-CLOUD/kubernetes/` 병합 ✅
- [x] **4.2.2** `README.md` → `k8s-learning-log.md`로 복사 ✅
- [x] **4.2.3** `Kubectl_MOC.md`에 "학습 기록" 섹션 추가 ✅

---

## Phase 5: 루트 파일 + 사후 정리

- [ ] **5.1** pista의 `CLAUDE.md`와 MZ-CLOUD의 `CLAUDE.md` 비교 후 병합
- [ ] **5.2** 각 MOC 내 `[[wikilink]]`가 실제 파일과 매칭되는지 확인
- [ ] **5.3** 전체 파일 수 검증
- [ ] **5.4** `MZ-CLOUD.bak` 백업 삭제 (사용자 판단)

---

## 마이그레이션 결과 요약

| 디렉토리 | 파일 수 | MOC 파일 | 상태 |
|----------|--------|---------|------|
| `database/` | 47 | `Database_MOC.md` | ✅ |
| `on-premise-ict/` | 77 | `OnPremise_MOC.md` | ✅ |
| `personal-project/` | 61 | `PersonalProject_MOC.md` | ✅ |
| `linux/` | 4 | `Linux_MOC.md` | ✅ |
| `python/` | 2 | `Python_MOC.md` | ✅ |
| `docker/` (병합) | 58 | `Docker_MOC.md` 업데이트 | ✅ |
| `kubernetes/` (병합) | 111 | `Kubectl_MOC.md` 업데이트 | ✅ |
| **전체 MZ-CLOUD** | **650** | **19개 MOC** | |
