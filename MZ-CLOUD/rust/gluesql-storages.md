# GlueSQL 스토리지 백엔드

#gluesql #rust #storage #스토리지

---

14개 스토리지 구현. 모두 Store/StoreMut 트레이트 기반.

> 소스: `storages/`

## 인메모리

### memory-storage

```rust
use gluesql::prelude::*;
let storage = MemoryStorage::default();
let mut glue = Glue::new(storage);
```

| 항목 | 내용 |
|------|------|
| 크레이트 | `gluesql_memory_storage` |
| 의존성 | `async-trait`, `futures` |
| 데이터 | HashMap 기반 |
| 영속성 | 없음 (프로세스 종료 시 소멸) |
| 용도 | 테스트, 프로토타입, 임시 데이터 |

### shared-memory-storage

```rust
let storage = SharedMemoryStorage::default();
// 여러 tokio 태스크에서 공유 가능
```

| 항목 | 내용 |
|------|------|
| 크레이트 | `gluesql-shared-memory-storage` |
| 기반 | memory-storage + `tokio::sync` |
| 용도 | 멀티 태스크 인메모리 공유 |

---

## 임베디드 DB

### sled-storage

```rust
let storage = SledStorage::new("./data").unwrap();
let mut glue = Glue::new(storage);
```

| 항목 | 내용 |
|------|------|
| 크레이트 | `gluesql_sled_storage` |
| 의존성 | `sled`, `bincode`, `async-io` |
| 엔진 | B+ 트리 임베디드 DB |
| 영속성 | 디스크 |
| 트랜잭션 | 지원 |
| 인덱스 | 지원 |

### redb-storage

| 항목 | 내용 |
|------|------|
| 크레이트 | `gluesql-redb-storage` |
| 의존성 | `redb`, `uuid`, `async-stream` |
| 엔진 | 경량 트랜잭셔널 DB |
| 영속성 | 디스크 |

---

## 파일 기반

### json-storage

```rust
let storage = JsonStorage::new("./json_data").unwrap();
```

| 항목 | 내용 |
|------|------|
| 크레이트 | `gluesql-json-storage` |
| 의존성 | `serde_json`, `tokio` |
| 형식 | JSON / JSONL 파일 |
| 용도 | 로그, 설정, 데이터 교환 |

### csv-storage

| 항목 | 내용 |
|------|------|
| 크레이트 | `gluesql-csv-storage` |
| 의존성 | `csv`, `serde_json` |
| 형식 | CSV 파일 |
| 용도 | 데이터 분석, 가져오기/내보내기 |

### parquet-storage

| 항목 | 내용 |
|------|------|
| 크레이트 | `gluesql-parquet-storage` |
| 의존성 | `parquet`, `byteorder`, `rust_decimal` |
| 형식 | Apache Parquet (컬럼 형식) |
| 용도 | 대용량 분석, 데이터 레이크 |

### file-storage

| 항목 | 내용 |
|------|------|
| 크레이트 | `gluesql-file-storage` |
| 의존성 | `ron`, `hex`, `uuid` |
| 형식 | RON (Rusty Object Notation) |
| 용도 | 범용 파일 저장 |

### git-storage

| 항목 | 내용 |
|------|------|
| 크레이트 | `gluesql-git-storage` |
| 기반 | file-storage + csv-storage + json-storage |
| 용도 | Git 버전 관리 기반 데이터 저장 |

---

## 외부 서비스

### redis-storage

| 항목 | 내용 |
|------|------|
| 크레이트 | `gluesql-redis-storage` |
| 의존성 | `redis`, `chrono`, `serde_json` |
| 용도 | Redis를 SQL로 쿼리 |

### mongo-storage

| 항목 | 내용 |
|------|------|
| 크레이트 | `gluesql-mongo-storage` |
| 의존성 | `mongodb`, `bson`, `strum` |
| 용도 | MongoDB를 SQL로 쿼리 |

---

## 브라우저

### web-storage

| 항목 | 내용 |
|------|------|
| 크레이트 | `gluesql-web-storage` |
| 의존성 | `gloo-storage`, `web-sys` |
| 대상 | localStorage / sessionStorage |
| 환경 | 브라우저 (WASM) |

### idb-storage

| 항목 | 내용 |
|------|------|
| 크레이트 | `gluesql-idb-storage` |
| 의존성 | `idb`, `wasm-bindgen`, `web-sys` |
| 대상 | IndexedDB |
| 환경 | 브라우저 (WASM) |

---

## 특수

### composite-storage

여러 스토리지를 하나의 인스턴스에서 라우팅하여 사용한다.

```rust
// 테이블별로 다른 스토리지 사용
let composite = CompositeStorage::new()
    .push("memory", MemoryStorage::default())
    .push("json", JsonStorage::new("./data").unwrap());
```

---

## 스토리지 선택 가이드

| 상황 | 추천 스토리지 |
|------|-------------|
| 테스트/프로토타입 | `memory-storage` |
| 임베디드 영속성 | `sled-storage`, `redb-storage` |
| 데이터 교환 | `json-storage`, `csv-storage` |
| 대용량 분석 | `parquet-storage` |
| 기존 Redis/MongoDB | `redis-storage`, `mongo-storage` |
| 브라우저 앱 | `web-storage`, `idb-storage` |
| 여러 백엔드 조합 | `composite-storage` |

> [!info] 커스텀 스토리지
> `Store`/`StoreMut` 트레이트를 구현하면 어떤 백엔드든 GlueSQL과 연동 가능하다.
> 상세: [[gluesql-store]]
