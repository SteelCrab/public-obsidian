# Cargo 프로젝트 생성

#rust #cargo #프로젝트

---

Cargo로 새 Rust 프로젝트를 생성한다.

| 명령어 | 설명 |
|--------|------|
| `cargo new 프로젝트명` | 바이너리 프로젝트 생성 |
| `cargo new 프로젝트명 --lib` | 라이브러리 프로젝트 생성 |
| `cargo init` | 현재 디렉토리에 프로젝트 초기화 |
| `cargo init --lib` | 현재 디렉토리에 라이브러리 초기화 |

## 프로젝트 구조

```
my-project/
├── Cargo.toml      # 프로젝트 설정
├── src/
│   └── main.rs     # 바이너리 진입점
└── .gitignore
```

라이브러리 프로젝트의 경우 `src/lib.rs`가 생성된다.

## Hello World

```rust
fn main() {
    println!("Hello, world!");
}
```

> [!info] cargo new vs init
> `cargo new`는 새 디렉토리를 생성하고, `cargo init`은 기존 디렉토리에서 초기화한다.
