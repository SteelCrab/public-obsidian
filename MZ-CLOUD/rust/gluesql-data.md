# GlueSQL Data 모듈

#gluesql #rust #data #value #타입

---

핵심 데이터 타입, 값, 스키마, 행을 정의한다.

> 소스: `core/src/data/`

## Value 열거형

```rust
pub enum Value {
    // 불리언
    Bool(bool),
    // 정수
    I8(i8), I16(i16), I32(i32), I64(i64), I128(i128),
    U8(u8), U16(u16), U32(u32), U64(u64), U128(u128),
    // 부동소수점
    F32(f32), F64(f64),
    Decimal(Decimal),
    // 문자열/바이너리
    Str(String), Bytea(Vec<u8>), Inet(IpAddr),
    // 날짜/시간
    Date(NaiveDate), Timestamp(NaiveDateTime), Time(NaiveTime),
    Interval(Interval),
    // 복합
    Uuid(u128), Map(HashMap<String, Value>), List(Vec<Value>),
    Point(Point),
    // NULL
    Null,
}
```

**20개 이상의 SQL 데이터 타입**을 네이티브로 지원한다.

## Value 서브모듈

| 파일 | 역할 |
|------|------|
| `binary_op.rs` | `Value + Value`, `Value > Value` 등 이항 연산 |
| `convert.rs` | 타입 간 변환 (광범위) |
| `date.rs` | 날짜/시간 파싱 |
| `expr.rs` | 값 기반 표현식 평가 |
| `json.rs` | JSON 변환 |
| `selector.rs` | JSON 경로 선택 |
| `uuid.rs` | UUID 파싱 |

## Schema 구조체

```rust
pub struct Schema {
    pub table_name: String,
    pub column_defs: Option<Vec<ColumnDef>>,  // None = 스키마리스
    pub indexes: Vec<SchemaIndex>,
    pub engine: Option<String>,
    pub foreign_keys: Vec<ForeignKey>,
    pub comment: Option<String>,
}
```

`column_defs`가 `None`이면 스키마리스(NoSQL) 모드로 동작한다.

## Row와 Key

```rust
// DataRow - 행 데이터
pub type DataRow = Vec<Value>;

// Key - 행 식별자
pub enum Key {
    I8(i8), I16(i16), I32(i32), I64(i64), I128(i128),
    U8(u8), U16(u16), U32(u32), U64(u64), U128(u128),
    Str(String), Bytea(Vec<u8>), Uuid(u128),
    Bool(bool), Date(NaiveDate), Timestamp(NaiveDateTime),
    Time(NaiveTime), Decimal(Decimal), Inet(IpAddr),
    None,
}
```

## 기타 데이터 모듈

| 파일 | 설명 |
|------|------|
| `interval.rs` | 시간 간격 타입 |
| `point.rs` | 기하학적 좌표 타입 |
| `string_ext.rs` | 문자열 유틸리티 |
| `bigdecimal_ext.rs` | 고정밀 소수 유틸리티 |

## 스키마리스 지원

```sql
-- 스키마 있는 테이블
CREATE TABLE users (id INT, name TEXT);

-- 스키마 없는 테이블 (NoSQL 스타일)
CREATE TABLE logs;
INSERT INTO logs VALUES ('{"id": 1, "msg": "hello"}');

-- 조인도 가능
SELECT * FROM users JOIN logs ON users.id = logs.id;
```

## 사용된 Rust 패턴

| 패턴 | 설명 | 관련 노트 |
|------|------|----------|
| 열거형 + 데이터 | 20+ variant의 Value | [[rust-enum]] |
| Option 활용 | `column_defs: Option<Vec<_>>` 스키마리스 | [[rust-option]] |
| HashMap/Vec | 복합 데이터 (Map, List) | [[rust-hashmap]], [[rust-vector]] |
| chrono 통합 | 날짜/시간 타입 | [[rust-crate-chrono]] |
| serde | JSON 변환 | [[rust-crate-serde]] |
