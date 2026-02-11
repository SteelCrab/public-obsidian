# sqlx - 비동기 SQL

#rust #sqlx #데이터베이스 #크레이트

---

컴파일 타임에 SQL 쿼리를 검증하는 비동기 SQL 라이브러리.

## 설치

```toml
[dependencies]
sqlx = { version = "0.8", features = ["runtime-tokio", "postgres"] }
tokio = { version = "1", features = ["full"] }
```

지원 DB: `postgres`, `mysql`, `sqlite`

## 연결

```rust
use sqlx::postgres::PgPoolOptions;

#[tokio::main]
async fn main() -> Result<(), sqlx::Error> {
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect("postgres://user:pass@localhost/mydb")
        .await?;

    Ok(())
}
```

## 쿼리 실행

```rust
// 단순 실행
sqlx::query("INSERT INTO users (name, email) VALUES ($1, $2)")
    .bind("김철수")
    .bind("kim@example.com")
    .execute(&pool)
    .await?;

// 단일 행 조회
let row: (i64, String) = sqlx::query_as(
    "SELECT id, name FROM users WHERE id = $1"
)
    .bind(1i64)
    .fetch_one(&pool)
    .await?;
```

## 구조체 매핑

```rust
#[derive(sqlx::FromRow)]
struct User {
    id: i64,
    name: String,
    email: String,
}

// 여러 행
let users: Vec<User> = sqlx::query_as::<_, User>(
    "SELECT id, name, email FROM users"
)
    .fetch_all(&pool)
    .await?;

// 단일 행
let user: User = sqlx::query_as("SELECT * FROM users WHERE id = $1")
    .bind(1i64)
    .fetch_one(&pool)
    .await?;

// Optional
let user: Option<User> = sqlx::query_as("SELECT * FROM users WHERE id = $1")
    .bind(999i64)
    .fetch_optional(&pool)
    .await?;
```

## 컴파일 타임 검증 (query! 매크로)

```rust
// DATABASE_URL 환경변수 필요
let user = sqlx::query_as!(
    User,
    "SELECT id, name, email FROM users WHERE id = $1",
    1i64
)
    .fetch_one(&pool)
    .await?;
```

## 마이그레이션

```bash
sqlx migrate add create_users_table   # 마이그레이션 파일 생성
sqlx migrate run                       # 마이그레이션 실행
```

> [!info] 컴파일 타임 검증
> `query!` 매크로는 빌드 시 실제 DB에 연결하여 쿼리를 검증한다.
> 오프라인 모드: `cargo sqlx prepare`로 메타데이터를 저장하면 DB 없이 빌드 가능.
