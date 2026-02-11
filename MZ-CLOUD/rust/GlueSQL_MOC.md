# GlueSQL MOC

#rust #gluesql #MOC #데이터베이스

---

GlueSQL 프로젝트의 아키텍처와 핵심 모듈을 연결하는 허브 노트.
Rust로 작성된 멀티 모델 SQL 데이터베이스 엔진 라이브러리.

---

## 프로젝트 개요

| 항목 | 내용 |
|------|------|
| 버전 | v0.18.0 |
| 언어 | Rust (Edition 2024) |
| 라이선스 | Apache 2.0 |
| SQL 파서 | sqlparser-rs (PostgreSQL 방언) |
| 바인딩 | Rust, JavaScript (WASM), Python (PyO3) |
| 저장소 | 14개 스토리지 백엔드 |

---

## 프로젝트 구조

```
gluesql/
├── core/               # 핵심 엔진 (파서, AST, 실행기, 플래너)
├── storages/           # 14개 스토리지 백엔드
│   ├── memory-storage/
│   ├── sled-storage/
│   ├── json-storage/
│   ├── csv-storage/
│   ├── parquet-storage/
│   ├── redb-storage/
│   ├── file-storage/
│   ├── git-storage/
│   ├── redis-storage/
│   ├── mongo-storage/
│   ├── web-storage/
│   ├── idb-storage/
│   ├── shared-memory-storage/
│   └── composite-storage/
├── cli/                # CLI REPL 도구
├── pkg/
│   ├── rust/           # Rust 패키지 (gluesql 크레이트)
│   ├── javascript/     # WASM 바인딩 (gluesql-js)
│   └── python/         # Python 바인딩 (gluesql-py)
├── macros/             # FromGlueRow derive 매크로
├── utils/              # 유틸리티
├── test-suite/         # 58개 테스트 모듈
└── Cargo.toml          # 워크스페이스 루트
```

---

## 핵심 아키텍처

```
SQL 텍스트
    ↓
[parse_sql] → sqlparser-rs (PostgreSQL 방언)
    ↓
[translate] → SqlStatement → GlueSQL AST (Statement)
    ↓
[plan] → 쿼리 계획 (인덱스 최적화)
    ↓
[executor] → 실행 + Store 트레이트 호출
    ↓
[Payload] → Select/Insert/Update/Delete 결과
```

---

## 핵심 모듈 (Core)

- [[gluesql-glue-api]] - Glue\<T\> 메인 API (parse → plan → execute)
- [[gluesql-ast]] - AST 정의 (데이터 타입, DDL, DML, 표현식)
- [[gluesql-ast-builder]] - 프로그래밍 방식 쿼리 빌더
- [[gluesql-translate]] - SQL → AST 변환 (sqlparser-rs 연동)
- [[gluesql-plan]] - 쿼리 플래너 (인덱스 최적화)
- [[gluesql-executor]] - SQL 실행 엔진 (22개 서브모듈)
- [[gluesql-store]] - Store/StoreMut 트레이트 (스토리지 추상화)
- [[gluesql-data]] - Value 타입, Schema, Row, Key

---

## 스토리지 백엔드

- [[gluesql-storages]] - 14개 스토리지 구현 상세

### 인메모리

| 스토리지 | 설명 |
|----------|------|
| `memory-storage` | HashMap 기반 인메모리 |
| `shared-memory-storage` | tokio 태스크 간 공유 메모리 |

### 임베디드 DB

| 스토리지 | 설명 |
|----------|------|
| `sled-storage` | sled B+ 트리 임베디드 DB |
| `redb-storage` | redb 경량 트랜잭셔널 DB |

### 파일 기반

| 스토리지 | 설명 |
|----------|------|
| `json-storage` | JSON/JSONL 파일 |
| `csv-storage` | CSV 파일 |
| `parquet-storage` | Apache Parquet 컬럼 형식 |
| `file-storage` | RON 형식 파일 |
| `git-storage` | Git 버전 관리 기반 |

### 외부 서비스

| 스토리지 | 설명 |
|----------|------|
| `redis-storage` | Redis 백엔드 |
| `mongo-storage` | MongoDB 백엔드 |

### 브라우저

| 스토리지 | 설명 |
|----------|------|
| `web-storage` | localStorage/sessionStorage |
| `idb-storage` | IndexedDB |

### 특수

| 스토리지 | 설명 |
|----------|------|
| `composite-storage` | 여러 스토리지 라우팅 조합 |

---

## CLI와 바인딩

- [[gluesql-cli]] - CLI REPL (SQL 실행, 덤프, 다중 스토리지)
- [[gluesql-macros]] - FromGlueRow derive 매크로
- [[gluesql-bindings]] - 멀티 언어 바인딩 (Rust, JS, Python)

---

## 빠른 참조

| 상황 | 노트 |
|------|------|
| 프로젝트 시작 | [[gluesql-glue-api]] |
| SQL 실행 흐름 | [[gluesql-translate]] → [[gluesql-plan]] → [[gluesql-executor]] |
| 커스텀 스토리지 구현 | [[gluesql-store]] |
| 지원 스토리지 목록 | [[gluesql-storages]] |
| AST 직접 빌드 | [[gluesql-ast-builder]] |
| 행 → 구조체 변환 | [[gluesql-macros]] |
| Value 타입 체계 | [[gluesql-data]] |
| CLI 사용 | [[gluesql-cli]] |

---

## 관련 Rust 개념

| 개념 | 노트 |
|------|------|
| 트레이트 추상화 (Store) | [[rust-traits]], [[rust-trait-bounds]] |
| 제네릭 (Glue\<T\>) | [[rust-generics]] |
| 열거형 (Value, Payload) | [[rust-enum]], [[rust-pattern-matching]] |
| async/await | [[rust-async]], [[rust-crate-tokio]] |
| 에러 처리 (thiserror) | [[rust-crate-anyhow]] |
| derive 매크로 | [[rust-macros]] |
| 워크스페이스 | [[rust-cargo-workspace]] |
| 모듈 시스템 | [[rust-modules]] |
| HashMap/Vec | [[rust-hashmap]], [[rust-vector]] |
| 직렬화 (serde) | [[rust-crate-serde]] |

---

## PipeSQL과 비교

| 항목 | GlueSQL | PipeSQL |
|------|---------|---------|
| 상태 | 프로덕션 레벨 (v0.18) | 초기 개발 (Phase 1) |
| SQL 파서 | sqlparser-rs 사용 | 미구현 |
| 스토리지 | 14개 백엔드 | HashMap (1개) |
| 바인딩 | Rust/JS/Python | Rust only |
| 동시성 | async-trait | 예정 (DashMap) |
| TUI | CLI REPL | ratatui TUI |

---

## 외부 링크

- [GlueSQL 공식 문서](https://gluesql.org/docs)
- [crates.io](https://crates.io/crates/gluesql)
- [GitHub](https://github.com/gluesql/gluesql)
- [docs.rs](https://docs.rs/gluesql/)

---

*Zettelkasten 스타일로 구성됨*
