# Cargo.toml 설정

#rust #cargo #설정

---

프로젝트 메타데이터와 의존성을 정의하는 매니페스트 파일.

```toml
[package]
name = "my-project"
version = "0.1.0"
edition = "2021"

[dependencies]
serde = "1.0"
serde_json = "1.0"

[dev-dependencies]
tokio-test = "0.4"

[[bin]]
name = "my-app"
path = "src/main.rs"
```

## 주요 섹션

| 섹션 | 설명 |
|------|------|
| `[package]` | 프로젝트 이름, 버전, 에디션 |
| `[dependencies]` | 런타임 의존성 |
| `[dev-dependencies]` | 테스트/개발 의존성 |
| `[build-dependencies]` | 빌드 스크립트 의존성 |
| `[[bin]]` | 바이너리 타겟 설정 |
| `[features]` | 피처 플래그 정의 |

## 버전 지정

| 표기 | 의미 |
|------|------|
| `"1.0"` | `>=1.0.0, <2.0.0` |
| `"=1.0.4"` | 정확히 1.0.4 |
| `">=1.0, <1.5"` | 범위 지정 |
| `{ git = "url" }` | Git 저장소에서 가져오기 |
| `{ path = "../lib" }` | 로컬 경로 참조 |
