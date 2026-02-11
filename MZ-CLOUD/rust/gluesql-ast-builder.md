# GlueSQL AST Builder

#gluesql #rust #ast #쿼리빌더

---

SQL 문자열 대신 Rust 코드로 직접 쿼리를 구성하는 빌더 API.

> 소스: `core/src/ast_builder/`

## 기본 사용

```rust
use gluesql::core::ast_builder::*;

// SELECT id, name FROM users WHERE age > 20 ORDER BY name
let query = table("users")
    .select()
    .filter(col("age").gt(20))
    .project("id, name")
    .order_by("name")
    .execute(&mut glue)
    .await;
```

## 주요 빌더 함수

### 테이블과 값

| 함수 | 설명 |
|------|------|
| `table("name")` | 테이블 참조 |
| `col("name")` | 컬럼 참조 |
| `num(42)` | 숫자 리터럴 |
| `text("hello")` | 문자열 리터럴 |
| `date("2024-01-15")` | 날짜 리터럴 |
| `timestamp("...")` | 타임스탬프 리터럴 |
| `uuid("...")` | UUID 리터럴 |
| `null()` | NULL 값 |

### CRUD 쿼리

```rust
// INSERT
table("users")
    .insert()
    .values(vec!["1, 'kim'", "2, 'lee'"])
    .execute(&mut glue).await;

// UPDATE
table("users")
    .update()
    .set("name", text("park"))
    .filter(col("id").eq(1))
    .execute(&mut glue).await;

// DELETE
table("users")
    .delete()
    .filter(col("age").lt(20))
    .execute(&mut glue).await;

// SELECT
table("users")
    .select()
    .project("id, name")
    .filter(col("age").gte(20))
    .order_by("name ASC")
    .limit(10)
    .offset(20)
    .execute(&mut glue).await;
```

### 집계 함수

| 함수 | SQL |
|------|-----|
| `count("*")` | `COUNT(*)` |
| `sum("price")` | `SUM(price)` |
| `avg("score")` | `AVG(score)` |
| `min("age")` | `MIN(age)` |
| `max("age")` | `MAX(age)` |
| `stdev("val")` | `STDEV(val)` |
| `variance("val")` | `VARIANCE(val)` |

### 조인

```rust
table("users")
    .select()
    .join("orders")
    .on("users.id = orders.user_id")
    .project("users.name, orders.total")
    .execute(&mut glue).await;
```

### 트랜잭션

```rust
begin().execute(&mut glue).await;
// ... 쿼리 실행 ...
commit().execute(&mut glue).await;
// 또는
rollback().execute(&mut glue).await;
```

## SQL vs AST Builder 비교

```rust
// SQL 방식
glue.execute("SELECT name FROM users WHERE age > 20").await;

// AST Builder 방식
table("users")
    .select()
    .filter(col("age").gt(20))
    .project("name")
    .execute(&mut glue).await;
```

## 사용된 Rust 패턴

| 패턴 | 설명 | 관련 노트 |
|------|------|----------|
| 빌더 패턴 | 메서드 체이닝 | [[rust-struct]] |
| 클로저 | 필터 표현식 | [[rust-closures]] |
| async/await | `.execute().await` | [[rust-async]] |

> [!tip] AST Builder vs ORM
> GlueSQL의 AST Builder는 ORM이 아니라 AST를 직접 구성한다.
> SQL의 모든 기능을 Rust 타입 시스템으로 사용할 수 있다.
