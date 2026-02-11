# Rust Cargo 워크스페이스

#rust #cargo #워크스페이스

---

여러 패키지를 하나의 프로젝트에서 관리한다.

## 구조

```
my-workspace/
├── Cargo.toml          # 워크스페이스 루트
├── app/
│   ├── Cargo.toml
│   └── src/main.rs
├── core-lib/
│   ├── Cargo.toml
│   └── src/lib.rs
└── utils/
    ├── Cargo.toml
    └── src/lib.rs
```

## 루트 Cargo.toml

```toml
[workspace]
members = [
    "app",
    "core-lib",
    "utils",
]

[workspace.dependencies]
serde = "1.0"
```

## 멤버 간 의존성

```toml
# app/Cargo.toml
[dependencies]
core-lib = { path = "../core-lib" }
utils = { path = "../utils" }
serde = { workspace = true }      # 워크스페이스 의존성 참조
```

## 빌드 명령어

| 명령어 | 설명 |
|--------|------|
| `cargo build` | 전체 워크스페이스 빌드 |
| `cargo build -p app` | 특정 패키지 빌드 |
| `cargo test` | 전체 테스트 |
| `cargo test -p core-lib` | 특정 패키지 테스트 |
| `cargo run -p app` | 특정 바이너리 실행 |

> [!tip] 공유 Cargo.lock
> 워크스페이스는 하나의 `Cargo.lock`을 공유하여 모든 패키지의 의존성 버전을 통일한다.
