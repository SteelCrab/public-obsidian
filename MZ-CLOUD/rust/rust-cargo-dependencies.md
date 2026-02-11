# Cargo 의존성 관리

#rust #cargo #의존성

---

외부 크레이트를 추가하고 관리한다.

| 명령어 | 설명 |
|--------|------|
| `cargo add serde` | 의존성 추가 |
| `cargo add serde --features derive` | 피처와 함께 추가 |
| `cargo add tokio --dev` | 개발 의존성 추가 |
| `cargo remove serde` | 의존성 제거 |
| `cargo update` | 의존성 업데이트 |
| `cargo tree` | 의존성 트리 확인 |

## Cargo.lock

`Cargo.lock`은 정확한 의존성 버전을 고정한다.

| 프로젝트 타입 | Cargo.lock 커밋 |
|---------------|-----------------|
| 바이너리 | 커밋한다 |
| 라이브러리 | 커밋하지 않는다 |

## 자주 쓰는 크레이트

| 크레이트 | 용도 |
|----------|------|
| `serde` | 직렬화/역직렬화 |
| `tokio` | 비동기 런타임 |
| `reqwest` | HTTP 클라이언트 |
| `clap` | CLI 인자 파싱 |
| `anyhow` | 에러 처리 간소화 |
| `thiserror` | 커스텀 에러 타입 |
