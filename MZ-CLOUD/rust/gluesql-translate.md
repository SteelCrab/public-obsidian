# GlueSQL Translate 모듈

#gluesql #rust #translate #파서

---

sqlparser-rs의 SQL 파싱 결과를 GlueSQL 내부 AST로 변환한다.

> 소스: `core/src/translate/`, `core/src/parse_sql/`

## 변환 파이프라인

```
SQL 텍스트
    ↓
parse_sql::parse(sql)          sqlparser-rs (PostgreSQL 방언)
    ↓
Vec<SqlStatement>              sqlparser의 AST
    ↓
translate::translate(stmt)     GlueSQL AST로 변환
    ↓
Statement                      GlueSQL 내부 AST
```

## 주요 함수

| 함수 | 설명 |
|--------|------|
| `parse(sql)` | SQL → sqlparser 구문 분석 (복수 문 지원) |
| `translate(statement)` | sqlparser AST → GlueSQL Statement |
| `translate_with_params(stmt, params)` | 매개변수화된 쿼리 변환 |
| `translate_query()` | SELECT 쿼리 변환 |
| `translate_expr()` | 표현식 변환 |
| `translate_data_type()` | 데이터 타입 변환 |
| `translate_column_def()` | 컬럼 정의 변환 |
| `translate_order_by_expr()` | ORDER BY 변환 |

## 서브모듈

| 파일 | 역할 |
|------|------|
| `translate.rs` | 메인 변환 로직 (22KB) |
| `data_type.rs` | SQL 타입 → DataType 매핑 |
| `ddl.rs` | CREATE/ALTER/DROP 변환 |
| `expr.rs` | 표현식 트리 변환 |
| `function.rs` | 함수 호출 변환 |
| `literal.rs` | 리터럴 값 변환 |
| `operator.rs` | 연산자 변환 |
| `param.rs` | 매개변수 바인딩 (`$1, $2`) |
| `query.rs` | SELECT/INSERT/UPDATE/DELETE 변환 |

## parse_sql 모듈

```rust
// PostgreSQL 방언으로 파싱
pub fn parse(sql: &str) -> Result<Vec<SqlStatement>> {
    Parser::parse_sql(&PostgreSqlDialect {}, sql)
}
```

편의 함수도 제공:

| 함수 | 설명 |
|------|------|
| `parse_query(sql)` | SELECT 쿼리만 파싱 |
| `parse_expr(sql)` | 단일 표현식 파싱 |
| `parse_column_def(sql)` | 컬럼 정의 파싱 |
| `parse_data_type(sql)` | 데이터 타입 파싱 |

## 매개변수화된 쿼리

```rust
let params = vec![
    ParamLiteral::Number("42".to_string()),
    ParamLiteral::Text("kim".to_string()),
];

glue.execute_with_params(
    "SELECT * FROM users WHERE id = $1 AND name = $2",
    params
).await;
```

## 사용된 Rust 패턴

| 패턴 | 설명 | 관련 노트 |
|------|------|----------|
| 패턴 매칭 | SqlStatement → Statement 변환 | [[rust-pattern-matching]] |
| Result 에러 처리 | 파싱/변환 실패 전파 | [[rust-result]] |
| Box 재귀 타입 | AST 트리 구조 | [[rust-smart-pointers]] |
| 외부 크레이트 연동 | sqlparser-rs | [[rust-cargo-dependencies]] |
