---
description: CI/CD 파이프라인 구현 문서를 구조화된 템플릿 형식으로 작성
---

# CI/CD 구현 템플릿

CI/CD 파이프라인 구현 문서를 작성할 때 다음 구조를 따른다.
GitHub + Obsidian 양쪽에서 깔끔하게 렌더링되도록 순수 마크다운만 사용한다.

## 문서 구조

각 배포 방식 섹션은 반드시 아래 순서를 따른다:

### 1. 제목 + 한줄 개요
- `## N. 배포 방식 제목` 형식
- `>` blockquote로 한줄 설명 (다른 배포 방식과 비교 언급)

### 2. 파이프라인 흐름도 (간결한 ASCII)
- 코드 블록으로 감싸기
- trigger → build → push → deploy 흐름 표현
- 최대 10줄 이내

```
push main → GitHub Actions
  └── Build Docker Image
      └── Push to ECR
          └── Deploy to EKS (kubectl apply)
```

### 3. 배포 방식 비교 테이블 (해당 시에만)
- 다른 배포 방식과의 차이점
- 대상, 접속 방식, 이미지 저장소, LB, 스케일링 등

### 4. 시크릿 / 환경변수 테이블
- GitHub Secrets 또는 환경변수 목록 정리
- 3열: `이름`, `설명`, `설정 방법`

| 이름 | 설명 | 설정 방법 |
|------|------|----------|
| `AWS_ACCESS_KEY_ID` | AWS 액세스 키 | IAM → Security Credentials |
| `ECR_REGISTRY` | ECR 레지스트리 URI | `<ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com` |

### 5. 워크플로우 구현 (단계별 YAML)
- `**N단계: 제목**` 형식으로 단계 구분
- 각 단계 바로 아래에 `yaml` 코드 블록으로 해당 step/job 배치
- 시크릿은 `${{ secrets.NAME }}` 형태로 사용
- 주석(`#`)으로 핵심 설명만 간결하게

단계 분류 기준:
1. **트리거 설정** — on: push/pull_request/workflow_dispatch
2. **환경 준비** — checkout, AWS credentials, Docker login
3. **빌드 & 푸시** — Docker build, tag, push
4. **배포** — SSH/SSM/kubectl/argocd 등
5. **검증** — health check, smoke test

### 6. 사전 준비 / 인프라 요구사항 (해당 시에만)
- 배포에 필요한 인프라 (EC2, EKS, ECR 등)
- IAM 역할/정책 요구사항
- 테이블 또는 불릿 리스트로 정리

### 7. 검증 방법
- 배포 후 확인 명령어
- Health check URL, 로그 확인 방법

### 8. 관련 노트 링크
- 표준 마크다운 링크 사용 `[이름](./경로.md)`

## 금지 사항

- `[[wikilink]]` 사용 금지 → `[text](./path.md)` 사용
- ` ```table-of-contents``` ` 플러그인 코드 금지
- `<details>` 등 HTML 태그 금지
- 하드코딩된 시크릿 값 금지 → `${{ secrets.NAME }}` 또는 `<PLACEHOLDER>` 사용
- 전체 워크플로우 YAML을 한 블록으로 붙여넣기 금지 → 단계별로 분리 설명
- 장황한 설명 금지 → YAML 주석으로 충분

## CI/CD 특화 규칙

- 워크플로우 파일 경로 항상 명시: `.github/workflows/<filename>.yaml`
- 트리거 조건 (`paths`, `branches`) 명확히 기술
- Docker 이미지 태그 전략 명시 (latest, git SHA, 날짜 등)
- 멀티 스테이지 빌드 권장 (빌드 → 런타임 분리)
- Rollback 방법 포함 권장

## 참고

GCP/AWS 구현 템플릿의 구조를 파이프라인 흐름에 맞게 적용한 것.
