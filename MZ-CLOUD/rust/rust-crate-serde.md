# serde - 직렬화/역직렬화

#rust #serde #직렬화 #크레이트

---

Rust의 대표적인 직렬화 프레임워크. JSON, TOML, YAML 등 다양한 포맷을 지원한다.

## 설치

```toml
[dependencies]
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
```

## 기본 사용

```rust
use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize, Debug)]
struct User {
    name: String,
    age: u32,
    email: Option<String>,
}

fn main() -> Result<(), serde_json::Error> {
    // 구조체 → JSON
    let user = User {
        name: "김철수".to_string(),
        age: 30,
        email: Some("kim@example.com".to_string()),
    };
    let json = serde_json::to_string(&user)?;
    let pretty = serde_json::to_string_pretty(&user)?;

    // JSON → 구조체
    let json_str = r#"{"name":"이영희","age":25,"email":null}"#;
    let user: User = serde_json::from_str(json_str)?;

    Ok(())
}
```

## 어트리뷰트

```rust
#[derive(Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]      // 필드 이름 변환
struct ApiResponse {
    #[serde(rename = "user_id")]        // 특정 필드 이름 변경
    id: u32,

    #[serde(default)]                   // 없으면 기본값
    active: bool,

    #[serde(skip_serializing_if = "Option::is_none")]  // None이면 생략
    nickname: Option<String>,

    #[serde(skip)]                      // 직렬화/역직렬화 제외
    internal: String,
}
```

## 주요 포맷 크레이트

| 크레이트 | 포맷 |
|----------|------|
| `serde_json` | JSON |
| `serde_yaml` | YAML |
| `toml` | TOML |
| `serde_csv` | CSV |
| `bincode` | 바이너리 |

> [!tip] Value 타입
> 구조체 없이도 `serde_json::Value`로 동적 JSON을 다룰 수 있다.
> `serde_json::json!({ "key": "value" })` 매크로도 유용하다.
