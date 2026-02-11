# anyhow & thiserror - 에러 처리

#rust #anyhow #thiserror #에러처리 #크레이트

---

`anyhow`는 애플리케이션용, `thiserror`는 라이브러리용 에러 처리 크레이트.

## 설치

```toml
[dependencies]
anyhow = "1.0"
thiserror = "2.0"
```

## anyhow (애플리케이션용)

모든 에러를 하나의 `anyhow::Error` 타입으로 통합한다.

```rust
use anyhow::{Context, Result, bail, ensure};

fn read_config(path: &str) -> Result<Config> {
    let content = std::fs::read_to_string(path)
        .context("설정 파일을 읽을 수 없음")?;     // 에러에 컨텍스트 추가

    let config: Config = serde_json::from_str(&content)
        .context("JSON 파싱 실패")?;

    ensure!(config.port > 0, "포트 번호는 양수여야 합니다");  // 조건 검사

    if config.name.is_empty() {
        bail!("이름이 비어있음");    // 즉시 에러 반환
    }

    Ok(config)
}

fn main() -> Result<()> {
    let config = read_config("config.json")?;
    println!("포트: {}", config.port);
    Ok(())
}
```

## thiserror (라이브러리용)

커스텀 에러 타입을 쉽게 정의한다.

```rust
use thiserror::Error;

#[derive(Error, Debug)]
enum AppError {
    #[error("IO 에러: {0}")]
    Io(#[from] std::io::Error),

    #[error("파싱 에러: {0}")]
    Parse(#[from] serde_json::Error),

    #[error("유효하지 않은 입력: {msg}")]
    InvalidInput { msg: String },

    #[error("사용자 {id}를 찾을 수 없음")]
    UserNotFound { id: u64 },
}

fn process(input: &str) -> Result<(), AppError> {
    if input.is_empty() {
        return Err(AppError::InvalidInput {
            msg: "빈 입력".to_string(),
        });
    }
    Ok(())
}
```

## 사용 가이드

| 상황 | 크레이트 |
|------|---------|
| 바이너리/애플리케이션 | `anyhow` |
| 라이브러리 | `thiserror` |
| 빠른 프로토타입 | `anyhow` |
| 호출자에게 에러 종류 노출 | `thiserror` |

> [!tip] 조합 사용
> 라이브러리에서 `thiserror`로 에러 정의 → 애플리케이션에서 `anyhow`로 통합 처리.
