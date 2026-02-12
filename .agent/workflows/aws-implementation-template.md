---
description: AWS 구현 문서를 구조화된 템플릿 형식으로 작성
---

# AWS 구현 템플릿

AWS 인프라 구현 문서를 작성할 때 다음 구조를 따른다.
GitHub + Obsidian 양쪽에서 깔끔하게 렌더링되도록 순수 마크다운만 사용한다.

## 문서 구조

각 구현 섹션은 반드시 아래 순서를 따른다:

### 1. 제목 + 한줄 개요
- `## N. 섹션 제목` 형식
- `>` blockquote로 한줄 설명 (GCP 등 비교 대상이 있으면 언급)

### 2. 아키텍처 (간결한 ASCII 트리)
- 코드 블록으로 감싸기
- 사용자 요청 흐름을 위에서 아래로 표현
- 리소스 이름은 플레이스홀더(`<ALB_DNS>`) 사용
- 최대 15줄 이내로 핵심만

```
사용자 → http://<ALB_DNS>
  └── ALB (port:80)
      └── Target Group → ASG
          └── Launch Template (t3.micro, Nginx)
```

### 3. GCP vs AWS 비교 테이블 (해당 시에만)
- GCP 경험이 있는 사용자를 위한 매핑 테이블
- 불필요하면 생략

### 4. 플레이스홀더 테이블
- 해당 섹션에서 사용하는 모든 변수를 정리
- 3열: `변수`, `설명`, `예시`
- AWS CLI에서는 `--query`, `--output text` 등으로 값을 변수에 할당하는 패턴 권장

| 변수 | 설명 | 예시 |
|------|------|------|
| `VPC_ID` | VPC ID | `aws ec2 describe-vpcs --query ...` |
| `REGION` | 리전 | `ap-northeast-2` |

### 5. 구현 프로세스 (단계별 명령어)
- `**N단계: 제목**` 형식으로 단계 구분
- 각 단계 바로 아래에 `bash` 코드 블록으로 명령어 배치
- 명령어에서 리소스 이름/ID는 반드시 플레이스홀더 변수(`$VARIABLE`) 사용
- 리소스 생성 후 ID를 변수에 저장하는 패턴:
  ```bash
  VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 \
      --query 'Vpc.VpcId' --output text)
  ```
- 주석(`#`)으로 핵심 설명만 간결하게
- 마지막 단계는 항상 **확인** (describe, curl 등)

### 6. 관련 스크립트 / GitHub Actions 테이블 (해당 시에만)
- 자동화 스크립트나 워크플로우가 있으면 테이블로 정리

### 7. 관련 노트 링크
- 표준 마크다운 링크 사용 `[이름](./경로.md)`
- `[[wikilink]]` 사용 금지 (GitHub 미지원)

## 금지 사항

- `[[wikilink]]` 사용 금지 → `[text](./path.md)` 사용
- ` ```table-of-contents``` ` 플러그인 코드 금지
- `<details>` 등 HTML 태그 금지
- 하드코딩된 리소스 ID(i-xxx, vpc-xxx, sg-xxx) → 반드시 변수 사용
- 같은 다이어그램 중복 금지 (아키텍처는 섹션당 1개)
- 장황한 설명 금지 → 명령어 + 주석으로 충분

## AWS 특화 규칙

- 리소스 생성 후 **ID를 변수에 즉시 할당** (`--query ... --output text`)
- `--tag-specifications` 로 Name 태그 항상 포함
- 보안 그룹은 인바운드/아웃바운드 규칙을 테이블로 정리
- IAM 역할/정책은 JSON을 코드 블록으로 포함
- `--profile` 사용 시 플레이스홀더 테이블에 명시

## 참고 예시

GCP 구현 템플릿(`/gcp-implementation-template`)의 구조를 AWS CLI에 맞게 적용할 것.
