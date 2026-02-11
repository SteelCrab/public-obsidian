# PipeSQL Table 구조체

#pipesql #rust #storage #table

---

테이블의 이름, 스키마, 행 데이터를 관리하는 핵심 구조체.

> 소스: `src/storage/table.rs`

## 구조체 정의

```rust
#[derive(Debug, PartialEq, Eq)]
pub struct Table {
    pub name: TableName,
    pub columns: Schema,
    pub rows: HashMap<u64, Row>,
}
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `name` | `TableName` | 검증된 테이블 이름 (뉴타입) |
| `columns` | `Schema` | 컬럼 정의 목록 |
| `rows` | `HashMap<u64, Row>` | 행 데이터 (ID → Row 매핑) |

## 생성

```rust
impl Table {
    pub fn new(name: String) -> Result<Self, TableError> {
        Ok(Self {
            name: TableName::new(name)?,   // 이름 검증
            columns: Schema::new()?,       // 빈 스키마
            rows: HashMap::new(),          // 빈 행 집합
        })
    }
}
```

`Table::new()`는 `Result`를 반환하며, 이름 검증과 스키마 초기화에서 에러가 발생할 수 있다.

## TableName (뉴타입 패턴)

```rust
#[derive(Debug, PartialEq, Eq)]
pub struct TableName(String);
```

`String`을 감싸는 뉴타입으로, 생성 시 유효성 검증을 강제한다.

| 메서드 | 반환 | 설명 |
|--------|------|------|
| `TableName::new(name)` | `Result<Self, TableError>` | 검증 후 생성 |
| `.as_str()` | `&str` | 내부 문자열 참조 |

### 검증 규칙

```rust
impl TableName {
    pub fn new(name: String) -> Result<Self, TableError> {
        if name.is_empty() {
            return Err(TableError::Init("Table name cannot be empty".to_string()));
        }
        if name.len() > 64 {
            return Err(TableError::Init("Table name exceeds maximum length".to_string()));
        }
        if name.contains(" ") {
            return Err(TableError::Init("Table name cannot be space".to_string()));
        }
        Ok(Self(name))
    }
}
```

| 조건 | 에러 메시지 |
|------|-----------|
| 빈 문자열 | `"Table name cannot be empty"` |
| 64자 초과 | `"Table name exceeds maximum length"` |
| 공백 포함 | `"Table name cannot be space"` |

## TableError

```rust
#[derive(Debug, Error)]
pub enum TableError {
    #[error("table init error: {0}")]
    Init(String),

    #[error("schema error: {0}")]
    Schema(#[from] SchemaError),
}
```

`thiserror`의 `#[from]`으로 `SchemaError → TableError` 자동 변환을 지원한다.

## 테스트

```rust
#[test]
fn new_table_name() -> Result<(), TableError> {
    let table_name = TableName::new(String::from("pista"))?;
    assert_eq!(table_name.as_str(), "pista".to_string());
    Ok(())
}

#[test]
fn err_table_name_empty() {
    let err = TableName::new(String::new());
    assert!(err.is_err());
    match err {
        Err(TableError::Init(msg)) => assert_eq!(msg, "Table name cannot be empty"),
        _ => panic!("Expected TableError::Init"),
    }
}

#[test]
fn err_table_name_maximum() {
    let table_name: String = iter::repeat("pista").take(20).collect();
    let err = TableName::new(table_name);
    assert!(err.is_err());
    match err {
        Err(TableError::Init(msg)) => assert_eq!(msg, "Table name exceeds maximum length"),
        _ => panic!("Expected TableError::Init"),
    }
}
```

## 사용된 Rust 패턴

| 패턴 | 설명 | 관련 노트 |
|------|------|----------|
| 뉴타입 | `TableName(String)` - 타입 안전성 강화 | [[rust-struct]] |
| Result 에러 처리 | `new()` → `Result<Self, TableError>` | [[rust-result]] |
| ? 연산자 | `TableName::new(name)?` 에러 전파 | [[rust-error-propagation]] |
| thiserror | `#[derive(Error)]`, `#[from]` | [[rust-crate-anyhow]] |
| HashMap | 행 저장소 `HashMap<u64, Row>` | [[rust-hashmap]] |
| match 에러 검증 | 테스트에서 에러 variant 매칭 | [[rust-error-testing]] |

> [!info] 향후 확장
> `HashMap`은 이후 `DashMap`으로 교체하여 락프리 동시 접근을 지원할 예정이다.
