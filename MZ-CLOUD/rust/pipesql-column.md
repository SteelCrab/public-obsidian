# PipeSQL Column 구조체

#pipesql #rust #storage #column

---

테이블 컬럼의 이름과 데이터 타입을 정의한다.

> 소스: `src/storage/column.rs`

## ColumnType 열거형

```rust
#[derive(Debug, PartialEq, Eq)]
pub enum ColumnType {
    Integer,
}
```

현재 `Integer` 타입만 지원한다. 향후 `Text`, `Boolean`, `Float` 등이 추가될 예정.

## Column 구조체

```rust
#[derive(Debug, PartialEq, Eq)]
pub struct Column {
    name: String,            // private
    data_type: ColumnType,   // private
}
```

필드가 `private`이므로 getter 메서드로 접근한다.

## 메서드

| 메서드 | 반환 | 설명 |
|--------|------|------|
| `Column::new(name, data_type)` | `Self` | 새 컬럼 생성 |
| `.name()` | `&str` | 컬럼 이름 참조 |
| `.data_type()` | `&ColumnType` | 데이터 타입 참조 |

```rust
impl Column {
    pub fn new(name: String, data_type: ColumnType) -> Self {
        Self { name, data_type }
    }
    pub fn name(&self) -> &str {
        &self.name
    }
    pub fn data_type(&self) -> &ColumnType {
        &self.data_type
    }
}
```

## 사용 예시

```rust
use crate::storage::column::{Column, ColumnType};

let col = Column::new("id".to_string(), ColumnType::Integer);
assert_eq!(col.name(), "id");
assert_eq!(col.data_type(), &ColumnType::Integer);
```

## 사용된 Rust 패턴

| 패턴 | 설명 | 관련 노트 |
|------|------|----------|
| 열거형 | `ColumnType` - 가능한 타입 집합 | [[rust-enum]] |
| 캡슐화 | private 필드 + getter 메서드 | [[rust-struct]] |
| impl 블록 | 생성자 + getter 패턴 | [[rust-struct]] |
| &str 반환 | 소유권 이전 없이 참조 반환 | [[rust-borrowing]] |

> [!info] 향후 확장
> SQL 데이터 타입 매핑이 필요하다:
> `INTEGER → Integer`, `TEXT → Text`, `BOOLEAN → Boolean`, `REAL → Float`
