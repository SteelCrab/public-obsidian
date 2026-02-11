# GlueSQL Glue\<T\> 메인 API

#gluesql #rust #api #glue

---

GlueSQL의 메인 진입점. 제네릭 스토리지 위에서 SQL을 실행한다.

> 소스: `core/src/glue.rs`

## 구조체 정의

```rust
pub struct Glue<T: GStore + GStoreMut + Planner> {
    pub storage: T,
}
```

스토리지 타입 `T`에 대해 제네릭하다. `T`는 `GStore + GStoreMut + Planner` 트레이트를 구현해야 한다.

## 주요 메서드

| 메서드 | 설명 |
|--------|------|
| `Glue::new(storage)` | 스토리지로 인스턴스 생성 |
| `.execute(sql)` | SQL 문자열 파싱 + 실행 |
| `.execute_with_params(sql, params)` | 매개변수화된 SQL 실행 |
| `.plan_with_params(sql, params)` | SQL → 실행 계획 생성 |

## 기본 사용

```rust
use gluesql::prelude::*;

let storage = MemoryStorage::default();
let mut glue = Glue::new(storage);

// SQL 실행
let result = glue.execute("CREATE TABLE users (id INT, name TEXT)").await;
glue.execute("INSERT INTO users VALUES (1, '김철수')").await;

// SELECT
let payload = glue.execute("SELECT * FROM users").await;
```

## FromGlueRow를 이용한 타입 변환

```rust
#[derive(gluesql::FromGlueRow)]
struct User {
    id: i64,
    name: String,
}

let rows = glue
    .execute("SELECT id, name FROM users")
    .await
    .rows_as::<User>()
    .unwrap();
```

## 실행 파이프라인

```
glue.execute(sql)
    ↓
parse(sql)              // sqlparser-rs로 SQL 파싱
    ↓
translate(statement)    // SqlStatement → GlueSQL Statement
    ↓
plan(statement)         // 쿼리 최적화 (인덱스 등)
    ↓
execute(statement)      // 실행 + 스토리지 호출
    ↓
Payload                 // 결과 반환
```

## Payload (실행 결과)

```rust
pub enum Payload {
    Select { labels: Vec<String>, rows: Vec<Vec<Value>> },
    Insert(usize),
    Update(usize),
    Delete(usize),
    CreateTable,
    DropTable,
    AlterTable,
    // ... 15+ variants
}
```

## Prelude

```rust
pub mod prelude {
    DataType, Key, Value,
    Payload, Glue, parse, translate,
    Error, Result,
    SelectExt, FromGlueRow,
    MemoryStorage, SledStorage, // ...
}
```

## 사용된 Rust 패턴

| 패턴 | 설명 | 관련 노트 |
|------|------|----------|
| 제네릭 구조체 | `Glue<T: GStore + GStoreMut>` | [[rust-generics]] |
| 트레이트 바운드 | 스토리지 추상화 | [[rust-trait-bounds]] |
| async/await | 모든 I/O가 비동기 | [[rust-async]] |
| 열거형 | `Payload` 결과 타입 | [[rust-enum]] |
| derive 매크로 | `#[derive(FromGlueRow)]` | [[gluesql-macros]] |
