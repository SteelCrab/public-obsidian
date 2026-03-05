# Terraform 문서 멀티 에이전트 워크플로우

#terraform #문서자동화 #ai에이전트 #opus #gemini #codex

---

Opus와 Gemini CLI를 병렬로 운용하고, Codex가 최종 반영을 담당하는 Obsidian 문서 구현 절차입니다.

## 역할 분담

- Opus: 문서 구조 설계, 복잡 개념 초안 작성, 한국어 문맥 정리
- Gemini CLI: 코드/문서 근거 탐색, 사실 검증, 누락 항목 탐지
- Codex: 노트 형식 정리, `[[위키링크]]` 연결, MOC 반영, 최종 저장

## 병렬 세션 운영

1. Planner(Opus)가 오늘 작성할 노트 목록과 완료 기준을 확정
2. Explorer(Gemini CLI)가 병렬로 근거를 수집하고 충돌 포인트를 표시
3. Writer/Linker(Codex)가 노트 생성 및 `[Terraform MOC](./Terraform_MOC.md)` 링크 반영
4. Reviewer(Sonnet 또는 Gemini)로 링크/태그/형식 품질 게이트 점검

## 세션 핸드오프 템플릿

```markdown
## HANDOFF
- Context: {topic}, {target_moc}
- Decisions: 태그/파일명/링크 규칙
- Artifacts: 생성/수정 파일 목록
- Open Issues: 미해결 이슈 0~3개
- Done Criteria: 다음 세션 완료 기준
```

## 품질 게이트

- 링크 무결성: 신규 노트당 `[[...]]` 2개 이상(MOC 1 + 관련 노트 1)
- 태그 일관성: 제목 바로 아래 태그 배치
- 형식 준수: 제목/태그/구분선/본문 구조 유지
- 중복 방지: 유사 파일명과 주제 중복 여부 사전 점검

| 명령어 | 설명 |
|--------|------|
| `claude -p --model opus "{prompt}"` | 계획/구조 설계 세션 실행 |
| `/opt/homebrew/bin/gemini -p "{prompt}"` | 병렬 탐색/검증 세션 실행 |
| `git checkout -b docs/terraform/agent-workflow` | 문서 작업 브랜치 생성 |
| `git commit -m "docs(terraform): add multi-agent workflow"` | 반영 커밋 생성 |

## 기본 운영안(최소 구성)

Planner(Opus) -> Explorer(Gemini CLI) 병렬 -> Writer/Linker(Codex) -> Reviewer 순서로 하루 1루프를 고정합니다.

[Terraform MOC](./Terraform_MOC.md)
