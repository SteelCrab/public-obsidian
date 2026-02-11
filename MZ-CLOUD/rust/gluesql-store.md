# GlueSQL Store 트레이트

#gluesql #rust #store #트레이트 #추상화

---

스토리지 백엔드 추상화 계층. 모든 스토리지는 이 트레이트를 구현한다.

> 소스: `core/src/store/`

## 핵심 트레이트

### Store (읽기)

```rust
#[async_trait]
pub trait Store {
    async fn fetch_schema(&self, table_name: &str) -> Result<Option<Schema>>;
    async fn fetch_all_schemas(&self) -> Result<Vec<Schema>>;
    async fn fetch_data(&self, table_name: &str, key: &Key) -> Result<Option<DataRow>>;
    async fn scan_data(&self, table_name: &str) -> Result<RowIter>;
}
```

### StoreMut (쓰기)

```rust
#[async_trait]
pub trait StoreMut {
    async fn insert_schema(&mut self, schema: &Schema) -> Result<()>;
    async fn delete_schema(&mut self, table_name: &str) -> Result<()>;
    async fn append_data(&mut self, table_name: &str, rows: Vec<DataRow>) -> Result<()>;
    async fn insert_data(&mut self, table_name: &str, rows: Vec<(Key, DataRow)>) -> Result<()>;
    async fn delete_data(&mut self, table_name: &str, keys: Vec<Key>) -> Result<()>;
}
```

### 보조 트레이트

| 트레이트 | 설명 |
|----------|------|
| `Index` | 인덱스 스캔 (읽기) |
| `IndexMut` | 인덱스 생성/삭제 |
| `Metadata` | 테이블 메타데이터 |
| `AlterTable` | ALTER TABLE 연산 |
| `Transaction` | BEGIN/COMMIT/ROLLBACK |
| `CustomFunction` | 사용자 정의 함수 (읽기) |
| `CustomFunctionMut` | 사용자 정의 함수 (쓰기) |
| `Planner` | 커스텀 쿼리 플래너 |

## 복합 트레이트 (Composite)

```rust
// 읽기 전용 복합
pub trait GStore: Store + Index + Metadata + CustomFunction {}

// 쓰기 가능 복합
pub trait GStoreMut: StoreMut + IndexMut + AlterTable
    + Transaction + CustomFunctionMut {}
```

`Glue<T>`의 타입 바운드: `T: GStore + GStoreMut + Planner`

## 커스텀 스토리지 구현 예시

```rust
use gluesql_core::store::{Store, StoreMut};
use async_trait::async_trait;

pub struct MyStorage {
    data: HashMap<String, Vec<DataRow>>,
}

#[async_trait]
impl Store for MyStorage {
    async fn fetch_schema(&self, table_name: &str) -> Result<Option<Schema>> {
        // 스키마 조회 로직
    }
    async fn scan_data(&self, table_name: &str) -> Result<RowIter> {
        // 데이터 스캔 로직
    }
    // ...
}

#[async_trait]
impl StoreMut for MyStorage {
    async fn insert_schema(&mut self, schema: &Schema) -> Result<()> {
        // 스키마 생성 로직
    }
    // ...
}
```

## 사용된 Rust 패턴

| 패턴 | 설명 | 관련 노트 |
|------|------|----------|
| 트레이트 추상화 | 스토리지 인터페이스 분리 | [[rust-traits]] |
| async 트레이트 | `#[async_trait]` 매크로 | [[rust-async]] |
| 복합 트레이트 바운드 | `GStore: Store + Index + ...` | [[rust-trait-bounds]] |
| 제네릭 | `Glue<T: GStore + GStoreMut>` | [[rust-generics]] |
| 의존성 역전 | 엔진이 스토리지에 의존하지 않음 | [[rust-traits]] |

> [!info] 14개 스토리지
> 이 트레이트를 구현한 14개 스토리지 백엔드가 존재한다.
> 상세 내용: [[gluesql-storages]]
