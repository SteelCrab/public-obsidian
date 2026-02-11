# reqwest - HTTP 클라이언트

#rust #reqwest #http #크레이트

---

간편한 HTTP 클라이언트 라이브러리. 동기/비동기 모두 지원한다.

## 설치

```toml
[dependencies]
reqwest = { version = "0.12", features = ["json"] }
tokio = { version = "1", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
```

## GET 요청

```rust
#[tokio::main]
async fn main() -> Result<(), reqwest::Error> {
    // 간단한 GET
    let body = reqwest::get("https://httpbin.org/get")
        .await?
        .text()
        .await?;

    // JSON 파싱
    let resp: serde_json::Value = reqwest::get("https://api.example.com/data")
        .await?
        .json()
        .await?;

    Ok(())
}
```

## POST 요청

```rust
use serde::{Serialize, Deserialize};

#[derive(Serialize)]
struct LoginRequest {
    username: String,
    password: String,
}

#[derive(Deserialize)]
struct LoginResponse {
    token: String,
}

let client = reqwest::Client::new();
let resp: LoginResponse = client.post("https://api.example.com/login")
    .json(&LoginRequest {
        username: "user".to_string(),
        password: "pass".to_string(),
    })
    .send()
    .await?
    .json()
    .await?;
```

## Client 재사용

```rust
let client = reqwest::Client::builder()
    .timeout(std::time::Duration::from_secs(10))
    .default_headers({
        let mut headers = reqwest::header::HeaderMap::new();
        headers.insert("Authorization", "Bearer token".parse().unwrap());
        headers
    })
    .build()?;

let resp = client.get("https://api.example.com/data")
    .header("Accept", "application/json")
    .query(&[("page", "1"), ("limit", "10")])
    .send()
    .await?;

println!("상태: {}", resp.status());
```

## 에러 처리

```rust
let resp = client.get("https://api.example.com/data").send().await?;

if resp.status().is_success() {
    let data: MyData = resp.json().await?;
} else {
    eprintln!("HTTP 에러: {}", resp.status());
}
```

> [!tip] 동기 모드
> `features = ["blocking"]`을 추가하면 `reqwest::blocking::get()` 동기 API를 사용할 수 있다.
