# tracing - 구조화된 로깅

#rust #tracing #로깅 #크레이트

---

구조화된 이벤트 기반 로깅/추적 프레임워크. `log` 크레이트의 후속.

## 설치

```toml
[dependencies]
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter"] }
```

## 기본 설정

```rust
use tracing::{info, warn, error, debug, trace};
use tracing_subscriber;

fn main() {
    // 기본 구독자 초기화
    tracing_subscriber::fmt::init();

    // 환경 변수 필터 (RUST_LOG=debug)
    tracing_subscriber::fmt()
        .with_env_filter("my_app=debug,tower_http=info")
        .init();

    info!("서버 시작");
    debug!("디버그 정보");
    warn!(port = 3000, "포트 사용 중");
    error!("에러 발생: {}", "상세 내용");
}
```

## 로그 레벨

| 레벨 | 매크로 | 용도 |
|------|--------|------|
| ERROR | `error!()` | 에러 |
| WARN | `warn!()` | 경고 |
| INFO | `info!()` | 정보 |
| DEBUG | `debug!()` | 디버그 |
| TRACE | `trace!()` | 상세 추적 |

## 구조화된 필드

```rust
info!(
    user_id = 42,
    action = "login",
    ip = "192.168.1.1",
    "사용자 로그인"
);
// 2024-01-01T00:00:00Z INFO my_app: 사용자 로그인 user_id=42 action="login" ip="192.168.1.1"
```

## 스팬 (Span)

```rust
use tracing::{info_span, instrument};

// 수동 스팬
let span = info_span!("요청 처리", request_id = "abc123");
let _guard = span.enter();
info!("처리 시작");

// #[instrument] 매크로 (자동 스팬)
#[instrument]
async fn process_order(order_id: u64) -> Result<(), Error> {
    info!("주문 처리");
    // 자동으로 order_id가 스팬에 포함됨
    Ok(())
}
```

> [!tip] axum과 통합
> `tower-http`의 `TraceLayer`를 사용하면 HTTP 요청/응답을 자동 추적할 수 있다.
