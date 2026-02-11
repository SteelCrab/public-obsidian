# GlueSQL Executor 모듈

#gluesql #rust #executor #실행엔진

---

최적화된 AST를 받아 실제 데이터 연산을 수행한다. 22개 서브모듈로 구성.

> 소스: `core/src/executor/`

## 서브모듈

| 파일 | 역할 |
|------|------|
| `execute.rs` | 메인 실행 오케스트레이터 |
| `fetch.rs` | 스토리지에서 데이터 조회 |
| `select.rs` | SELECT 쿼리 실행 |
| `insert.rs` | INSERT 실행 |
| `update.rs` | UPDATE 실행 |
| `delete.rs` | DELETE 실행 |
| `aggregate.rs` | 집계 함수 (COUNT, SUM, AVG...) |
| `join.rs` | JOIN 연산 |
| `filter.rs` | WHERE 절 필터링 |
| `sort.rs` | ORDER BY 정렬 |
| `limit.rs` | LIMIT/OFFSET 처리 |
| `evaluate.rs` | 표현식 평가 |
| `validate.rs` | 실행 전 검증 |
| `alter/` | ALTER TABLE 연산 |
| `context.rs` | 행 실행 컨텍스트 |
| `evaluate/` | 특화 평가기 |

## 실행 흐름 (SELECT)

```
execute(Statement::Query)
    ↓
fetch(table_name)              스토리지에서 전체 스캔 or 인덱스 스캔
    ↓
filter(rows, where_clause)     WHERE 조건 필터링
    ↓
join(left, right, condition)   JOIN (있는 경우)
    ↓
aggregate(rows, functions)     GROUP BY + 집계 함수
    ↓
sort(rows, order_by)           ORDER BY 정렬
    ↓
limit(rows, limit, offset)     LIMIT/OFFSET 적용
    ↓
project(rows, columns)         SELECT 컬럼 추출
    ↓
Payload::Select { labels, rows }
```

## 표현식 평가

```rust
// evaluate_stateless - 순수 함수형 평가
fn evaluate_stateless(expr: &Expr) -> Result<Value> {
    match expr {
        Expr::Literal(lit) => Ok(literal_to_value(lit)),
        Expr::BinaryOp { left, op, right } => {
            let l = evaluate(left)?;
            let r = evaluate(right)?;
            Ok(l.binary_op(op, &r)?)
        }
        // ...
    }
}
```

## Payload 결과 타입

```rust
pub enum Payload {
    Select { labels: Vec<String>, rows: Vec<Vec<Value>> },
    Insert(usize),           // 삽입된 행 수
    Update(usize),           // 수정된 행 수
    Delete(usize),           // 삭제된 행 수
    CreateTable,
    DropTable,
    AlterTable,
    CreateIndex,
    DropIndex,
    Begin, Commit, Rollback, // 트랜잭션
    ShowVariable(VariableValue),
    // ...
}
```

## 사용된 Rust 패턴

| 패턴 | 설명 | 관련 노트 |
|------|------|----------|
| 패턴 매칭 | Statement variant별 분기 | [[rust-pattern-matching]] |
| 반복자 체인 | filter → map → collect 파이프라인 | [[rust-iterators]], [[rust-iterator-adapters]] |
| async 스트림 | 행 단위 비동기 스트리밍 | [[rust-async]] |
| 순수 함수 | `evaluate_stateless` | [[rust-functions]] |
| 에러 전파 | `?` 연산자 체이닝 | [[rust-error-propagation]] |
