# Cargo 빌드와 실행

#rust #cargo #빌드

---

Cargo로 프로젝트를 빌드하고 실행한다.

| 명령어 | 설명 |
|--------|------|
| `cargo build` | 디버그 빌드 |
| `cargo build --release` | 릴리스 빌드 (최적화) |
| `cargo run` | 빌드 + 실행 |
| `cargo run --release` | 릴리스 모드로 실행 |
| `cargo check` | 컴파일 검사 (빌드 없이) |
| `cargo test` | 테스트 실행 |
| `cargo doc --open` | 문서 생성 및 열기 |
| `cargo clean` | 빌드 산출물 삭제 |

## 빌드 결과 경로

| 모드 | 경로 |
|------|------|
| 디버그 | `target/debug/프로젝트명` |
| 릴리스 | `target/release/프로젝트명` |

> [!tip] cargo check
> `cargo check`는 바이너리를 생성하지 않아 `cargo build`보다 빠르다.
> 코드 작성 중 빠른 검증에 유용하다.
