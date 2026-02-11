# axum - 웹 프레임워크

#rust #axum #웹 #크레이트

---

tokio 팀이 만든 인체공학적 웹 프레임워크. tower 기반.

## 설치

```toml
[dependencies]
axum = "0.8"
tokio = { version = "1", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
```

## Hello World

```rust
use axum::{Router, routing::get};

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/", get(|| async { "Hello, World!" }));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
```

## 라우팅과 핸들러

```rust
use axum::{
    Router, Json,
    extract::{Path, Query, State},
    routing::{get, post},
    http::StatusCode,
};
use serde::{Deserialize, Serialize};

#[derive(Serialize)]
struct User { id: u64, name: String }

#[derive(Deserialize)]
struct CreateUser { name: String }

#[derive(Deserialize)]
struct Pagination { page: Option<u32>, limit: Option<u32> }

// GET /users/:id
async fn get_user(Path(id): Path<u64>) -> Json<User> {
    Json(User { id, name: "김철수".to_string() })
}

// GET /users?page=1&limit=10
async fn list_users(Query(params): Query<Pagination>) -> Json<Vec<User>> {
    Json(vec![])
}

// POST /users
async fn create_user(
    Json(payload): Json<CreateUser>,
) -> (StatusCode, Json<User>) {
    let user = User { id: 1, name: payload.name };
    (StatusCode::CREATED, Json(user))
}

#[tokio::main]
async fn main() {
    let app = Router::new()
        .route("/users", get(list_users).post(create_user))
        .route("/users/{id}", get(get_user));

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
```

## 상태 공유

```rust
use std::sync::Arc;
use tokio::sync::Mutex;

#[derive(Clone)]
struct AppState {
    db: Arc<Mutex<Vec<User>>>,
}

async fn get_users(State(state): State<AppState>) -> Json<Vec<User>> {
    let users = state.db.lock().await;
    Json(users.clone())
}

let state = AppState { db: Arc::new(Mutex::new(vec![])) };
let app = Router::new()
    .route("/users", get(get_users))
    .with_state(state);
```

> [!info] 추출자 (Extractor)
> axum은 함수 시그니처에서 자동으로 요청 데이터를 추출한다.
> `Path`, `Query`, `Json`, `State`, `Headers` 등을 매개변수로 선언하면 된다.
