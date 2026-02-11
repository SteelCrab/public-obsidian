# GlueSQL AST 모듈

#gluesql #rust #ast #파서

---

SQL 문을 나타내는 추상 구문 트리(Abstract Syntax Tree) 정의.

> 소스: `core/src/ast/`

## 주요 서브모듈

| 파일 | 설명 |
|------|------|
| `data_type.rs` | SQL 데이터 타입 정의 |
| `ddl.rs` | DDL (CREATE, ALTER, DROP) |
| `query.rs` | SELECT, INSERT, UPDATE, DELETE |
| `expr.rs` | 표현식 (산술, 논리, 함수 호출) |
| `function.rs` | SQL 함수 (집계, 스칼라) |
| `literal.rs` | 리터럴 값 |
| `operator.rs` | 이항/단항 연산자 |

## DataType 열거형

```rust
pub enum DataType {
    Boolean,
    Int8, Int16, Int32, Int64, Int128,
    Uint8, Uint16, Uint32, Uint64, Uint128,
    Float32, Float64, Decimal,
    Text, Bytea, Inet,
    Date, Timestamp, Time, Interval,
    Uuid, Map, List, Point,
}
```

20개 이상의 SQL 데이터 타입을 지원한다.

## Statement 열거형 (최상위)

주요 SQL 문 종류:

| variant | SQL |
|---------|-----|
| `CreateTable` | `CREATE TABLE` |
| `DropTable` | `DROP TABLE` |
| `AlterTable` | `ALTER TABLE` |
| `Insert` | `INSERT INTO` |
| `Update` | `UPDATE SET` |
| `Delete` | `DELETE FROM` |
| `Query` | `SELECT` |
| `CreateIndex` | `CREATE INDEX` |
| `Begin/Commit/Rollback` | 트랜잭션 |

## Expr 열거형 (표현식)

```rust
pub enum Expr {
    Literal(AstLiteral),
    Column { name, table_alias },
    BinaryOp { left, op, right },
    UnaryOp { op, expr },
    Function(Box<Function>),
    Aggregate(Aggregate),
    Subquery(Box<Query>),
    InList { expr, list, negated },
    Between { expr, low, high, negated },
    IsNull { expr, negated },
    Case { operand, when_then, else_result },
    Cast { expr, data_type },
    // ...
}
```

## SQL → AST 흐름

```
"SELECT id FROM users WHERE age > 20"
    ↓
Statement::Query {
    body: SetExpr::Select {
        projection: [SelectItem::Expr(Expr::Column("id"))],
        from: TableFactor::Table { name: "users" },
        selection: Some(Expr::BinaryOp {
            left: Expr::Column("age"),
            op: BinaryOperator::Gt,
            right: Expr::Literal(AstLiteral::Number("20"))
        })
    }
}
```

## 사용된 Rust 패턴

| 패턴 | 설명 | 관련 노트 |
|------|------|----------|
| 열거형 + 재귀 | `Expr` - Box로 재귀 구조 | [[rust-enum]], [[rust-smart-pointers]] |
| 패턴 매칭 | executor에서 AST 매칭 | [[rust-pattern-matching]] |
| serde 직렬화 | AST 노드 직렬화 | [[rust-crate-serde]] |
