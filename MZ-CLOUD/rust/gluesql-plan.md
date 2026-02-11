# GlueSQL Plan 모듈

#gluesql #rust #plan #쿼리최적화

---

쿼리 실행 전 최적화 계획을 생성한다. 인덱스 활용 결정이 핵심.

> 소스: `core/src/plan/`

## 서브모듈

| 파일 | 역할 |
|------|------|
| `planner.rs` | 쿼리 계획 생성 메인 |
| `validate.rs` | 계획 검증 |
| `context.rs` | 플래닝 컨텍스트 |
| `error.rs` | 플래닝 에러 |
| `expr.rs` | 표현식 최적화 |
| `index.rs` | 인덱스 기반 최적화 |
| `join.rs` | JOIN 최적화 |
| `primary_key.rs` | 기본키 활용 |
| `schema.rs` | 스키마 조회 |

## 플래닝 흐름

```
Statement (AST)
    ↓
Planner::plan(statement)
    ├── Schema 조회 (컬럼, 인덱스 정보)
    ├── WHERE 절 분석 → 인덱스 사용 가능 여부
    ├── JOIN 전략 결정
    └── 최적화된 실행 계획
    ↓
Optimized Statement
    ↓
Executor
```

## Planner 트레이트

```rust
#[async_trait]
pub trait Planner {
    async fn plan(&self, statement: Statement) -> Result<Statement>;
}
```

각 스토리지는 자체 `Planner`를 구현하여 스토리지별 최적화를 수행할 수 있다.

## 인덱스 최적화 예시

```sql
-- 인덱스 있는 경우
CREATE INDEX idx_age ON users (age);
SELECT * FROM users WHERE age > 20;
-- → 인덱스 스캔 사용

-- 인덱스 없는 경우
SELECT * FROM users WHERE name = 'kim';
-- → 풀 테이블 스캔
```

## 사용된 Rust 패턴

| 패턴 | 설명 | 관련 노트 |
|------|------|----------|
| async 트레이트 | `#[async_trait] Planner` | [[rust-traits]], [[rust-async]] |
| 방문자 패턴 | AST 트리 순회 최적화 | [[rust-pattern-matching]] |
| 커스텀 확장 | 스토리지별 Planner 구현 | [[rust-trait-bounds]] |
