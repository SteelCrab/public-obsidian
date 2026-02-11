# PipeSQL Schema 구조체

#pipesql #rust #storage #schema

---

테이블의 컬럼 정의를 관리하는 구조체.

> 소스: `src/storage/schema.rs`

## 구조체 정의

```rust
#[derive(Debug, PartialEq, Eq)]
pub struct Schema {
    pub columns: Vec<Column>,
}
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `columns` | `Vec<Column>` | 컬럼 정의 목록 |

## 생성

```rust
impl Schema {
    pub fn new() -> Result<Self, SchemaError> {
        Ok(Self {
            columns: Vec::new(),
        })
    }
}
```

빈 컬럼 벡터로 초기화한다. `Result`를 반환하여 향후 초기화 검증 로직 추가에 대비한다.

## SchemaError

```rust
#[derive(Debug, Error)]
pub enum SchemaError {
    #[error("schema init error: {0}")]
    SchemaInitError(String),
}
```

`thiserror`로 정의한 에러 타입. `TableError`에서 `#[from]`으로 자동 변환된다.

## 의존 관계

```
Table
  └── Schema
        └── Vec<Column>
              └── Column { name, data_type: ColumnType }
```

## 사용된 Rust 패턴

| 패턴 | 설명 | 관련 노트 |
|------|------|----------|
| Vec 컬렉션 | 동적 컬럼 목록 관리 | [[rust-vector]] |
| derive 매크로 | `Debug, PartialEq, Eq` 자동 구현 | [[rust-macros]] |
| thiserror | 에러 타입 정의 | [[rust-crate-anyhow]] |
| Result 패턴 | `new()` → `Result<Self, SchemaError>` | [[rust-result]] |

> [!info] 향후 확장
> `CREATE TABLE`문 파싱 시 컬럼 추가 메서드(`add_column`)와 컬럼 이름 중복 검증이 필요하다.
