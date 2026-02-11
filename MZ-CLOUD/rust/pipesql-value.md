# PipeSQL Value와 Row

#pipesql #rust #storage #value

---

테이블에 저장되는 값과 행을 정의한다.

> 소스: `src/storage/value.rs`

## Value 열거형

```rust
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Value {
    Integer(i64),
    Null,
}
```

| variant | 설명 | Rust 타입 |
|---------|------|----------|
| `Integer(i64)` | 정수 값 | `i64` |
| `Null` | 빈 값 (SQL NULL) | - |

`Clone`을 구현하여 값을 복제할 수 있다.

## Row 구조체

```rust
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Row {
    pub values: Vec<Value>,
}
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `values` | `Vec<Value>` | 컬럼 순서에 맞는 값 목록 |

## 데이터 흐름

```
INSERT INTO users (id, age) VALUES (1, 25)
    ↓
Row {
    values: vec![
        Value::Integer(1),   // id
        Value::Integer(25),  // age
    ]
}
    ↓
Table.rows.insert(auto_id, row)
```

## Column → Value 매핑

| ColumnType | Value | 예시 |
|-----------|-------|------|
| `Integer` | `Value::Integer(i64)` | `Value::Integer(42)` |
| (향후) `Text` | `Value::Text(String)` | 미구현 |
| (향후) `Boolean` | `Value::Boolean(bool)` | 미구현 |
| NULL 허용 시 | `Value::Null` | `Value::Null` |

## 사용된 Rust 패턴

| 패턴 | 설명 | 관련 노트 |
|------|------|----------|
| 열거형 + 데이터 | `Integer(i64)` - variant에 값 포함 | [[rust-enum]] |
| derive 매크로 | `Debug, Clone, PartialEq, Eq` | [[rust-macros]] |
| Vec 컬렉션 | 동적 값 목록 | [[rust-vector]] |
| Option 유사 패턴 | `Null` variant → SQL NULL 표현 | [[rust-option]] |

## Table에서의 저장

```rust
// Table 구조체 내부
pub rows: HashMap<u64, Row>

// 행 삽입 (향후 구현)
let row = Row {
    values: vec![Value::Integer(1), Value::Integer(25)],
};
table.rows.insert(next_id, row);

// 행 조회
if let Some(row) = table.rows.get(&1) {
    for val in &row.values {
        match val {
            Value::Integer(n) => print!("{} ", n),
            Value::Null => print!("NULL "),
        }
    }
}
```

> [!info] 향후 확장
> `ColumnType`이 추가될 때마다 `Value`에도 대응하는 variant가 필요하다.
> `Display` 트레이트 구현으로 SELECT 결과 출력을 지원해야 한다.
