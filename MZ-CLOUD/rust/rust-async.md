# Rust async/await

#rust #async #비동기

---

비동기 프로그래밍. 런타임으로 tokio를 주로 사용한다.

## 기본 문법

```rust
async fn fetch_data() -> String {
    // 비동기 작업
    String::from("데이터")
}

async fn process() {
    let data = fetch_data().await;  // 완료까지 대기
    println!("{}", data);
}
```

## tokio 런타임

```toml
# Cargo.toml
[dependencies]
tokio = { version = "1", features = ["full"] }
```

```rust
#[tokio::main]
async fn main() {
    let result = fetch_data().await;
    println!("{}", result);
}
```

## 동시 실행

```rust
use tokio::join;

async fn task1() -> i32 { 1 }
async fn task2() -> i32 { 2 }

#[tokio::main]
async fn main() {
    // 동시 실행 (병렬 아님)
    let (a, b) = join!(task1(), task2());
    println!("{} {}", a, b);
}
```

## tokio::spawn

```rust
#[tokio::main]
async fn main() {
    let handle = tokio::spawn(async {
        // 별도 태스크로 실행
        42
    });

    let result = handle.await.unwrap();
    println!("{}", result);
}
```

## 주요 비동기 패턴

| 패턴 | 설명 |
|------|------|
| `join!` | 모든 future 완료 대기 |
| `select!` | 첫 번째 완료된 future 반환 |
| `tokio::spawn` | 별도 태스크로 실행 |
| `tokio::time::sleep` | 비동기 대기 |

> [!info] Future
> `async fn`은 `Future`를 반환한다. `.await`를 호출해야 실행된다.
> Rust의 async는 지연 평가(lazy)이다.
