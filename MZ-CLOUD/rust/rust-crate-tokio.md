# tokio - 비동기 런타임

#rust #tokio #비동기 #크레이트

---

Rust 비동기 프로그래밍의 표준 런타임. 네트워크 서버, 파일 I/O 등에 사용한다.

## 설치

```toml
[dependencies]
tokio = { version = "1", features = ["full"] }
```

## 기본 사용

```rust
#[tokio::main]
async fn main() {
    println!("Hello, async world!");
}
```

## 태스크 생성

```rust
use tokio::task;

#[tokio::main]
async fn main() {
    // 비동기 태스크 스폰
    let handle = task::spawn(async {
        "결과"
    });

    let result = handle.await.unwrap();

    // CPU 집약 작업 (블로킹 스레드풀)
    let handle = task::spawn_blocking(|| {
        heavy_computation()
    });
}
```

## 타이머

```rust
use tokio::time::{sleep, timeout, Duration};

// 대기
sleep(Duration::from_secs(1)).await;

// 타임아웃
match timeout(Duration::from_secs(5), async_operation()).await {
    Ok(result) => println!("성공: {:?}", result),
    Err(_) => println!("타임아웃!"),
}
```

## 동시 실행

```rust
use tokio::join;

let (a, b, c) = join!(
    fetch_data("url1"),
    fetch_data("url2"),
    fetch_data("url3"),
);
```

## 채널

```rust
use tokio::sync::mpsc;

let (tx, mut rx) = mpsc::channel(100);  // 버퍼 크기 100

tokio::spawn(async move {
    tx.send("hello").await.unwrap();
});

while let Some(msg) = rx.recv().await {
    println!("{}", msg);
}
```

## 파일 I/O

```rust
use tokio::fs;

let content = fs::read_to_string("file.txt").await?;
fs::write("output.txt", "hello").await?;
```

> [!info] 피처 플래그
> `features = ["full"]`은 모든 기능을 포함한다.
> 필요한 것만: `["rt-multi-thread", "macros", "net", "io-util", "time"]`
