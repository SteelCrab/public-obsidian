# GlueSQL FromGlueRow 매크로

#gluesql #rust #매크로 #derive

---

SQL 결과 행을 Rust 구조체로 자동 변환하는 절차적 매크로.

> 소스: `macros/src/lib.rs`

## 기본 사용

```rust
#[derive(gluesql::FromGlueRow)]
struct User {
    id: i64,
    name: String,
    email: Option<String>,  // NULL 가능
}

let rows = glue
    .execute("SELECT id, name, email FROM users")
    .await
    .rows_as::<User>()
    .unwrap();

// 단일 행
let user = glue
    .execute("SELECT * FROM users WHERE id = 1")
    .await
    .one_as::<User>()
    .unwrap();
```

## 컬럼 이름 변경

```rust
#[derive(FromGlueRow)]
struct User {
    id: i64,
    #[glue(rename = "user_name")]
    name: String,
}
```

`#[glue(rename = "...")]`로 SQL 컬럼명과 필드명을 매핑한다.

## 생성되는 코드

매크로가 자동으로 구현하는 메서드:

| 메서드 | 설명 |
|--------|------|
| `from_glue_row(labels, row)` | 행 → 구조체 변환 |
| `from_glue_row_with_idx(idx, labels, row)` | 인덱스 캐싱 최적화 버전 |
| `__glue_fields()` | 필드 메타데이터 (내부용) |

## 에러 타입

```rust
pub enum RowConversionError {
    MissingColumn(String),      // 컬럼이 결과에 없음
    NullNotAllowed(String),     // Option이 아닌데 NULL
    TypeMismatch(String),       // 타입 변환 실패
}
```

## SelectExt 트레이트

```rust
// Payload에 대한 확장 메서드
trait SelectExt {
    fn rows_as<T: FromGlueRow>(&self) -> Result<Vec<T>>;
    fn one_as<T: FromGlueRow>(&self) -> Result<T>;
}
```

## 의존성

| 크레이트 | 용도 |
|----------|------|
| `proc-macro2` | 토큰 스트림 |
| `quote` | Rust 코드 생성 |
| `syn` | Rust 문법 파싱 |

## 사용된 Rust 패턴

| 패턴 | 설명 | 관련 노트 |
|------|------|----------|
| 절차적 매크로 | `#[derive(FromGlueRow)]` | [[rust-macros]] |
| 트레이트 확장 | `SelectExt` | [[rust-traits]] |
| Option 활용 | NULL 가능 필드 | [[rust-option]] |
| Result 에러 | `RowConversionError` | [[rust-result]] |
