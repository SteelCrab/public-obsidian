# PipeSQL MOC

#rust #pipesql #MOC #데이터베이스

---

PipeSQL 프로젝트의 아키텍처와 구현을 연결하는 허브 노트.
경량 인메모리 관계형 DB로, QUIC 프로토콜과 락프리 동시성을 목표로 한다.

---

## 프로젝트 개요

| 항목 | 내용 |
|------|------|
| 언어 | Rust (Edition 2024) |
| 런타임 | tokio (비동기) |
| 동시성 | DashMap (락프리) |
| TUI | ratatui + crossterm |
| 프로토콜 | QUIC (예정) |
| 라이선스 | Apache 2.0 |

---

## 프로젝트 구조

```
pipesql/
├── src/
│   ├── main.rs              # 진입점
│   ├── lib.rs               # 모듈 선언
│   ├── repl/                # REPL 인터페이스
│   │   ├── app.rs           # 앱 상태와 이벤트 루프
│   │   ├── event.rs         # 키보드 이벤트 처리
│   │   └── ui.rs            # 터미널 UI 렌더링
│   └── storage/             # 스토리지 엔진
│       ├── table.rs         # 테이블 구조와 검증
│       ├── schema.rs        # 스키마 정의
│       ├── column.rs        # 컬럼 타입 정의
│       └── value.rs         # 값과 행 구조체
├── tests/                   # 통합 테스트
├── docs/                    # 문서
├── Cargo.toml
└── README.md
```

---

## 핵심 모듈

### Storage 엔진

- [[pipesql-table]] - Table 구조체와 TableName 뉴타입 (검증, HashMap 기반 행 저장)
- [[pipesql-schema]] - Schema 구조체 (Vec\<Column\> 관리, SchemaError)
- [[pipesql-column]] - Column 구조체와 ColumnType 열거형 (캡슐화 패턴)
- [[pipesql-value]] - Value 열거형 (Integer, Null)과 Row 구조체

### REPL 인터페이스

- [[pipesql-app]] - App 상태 관리, 메인 이벤트 루프, Default 구현
- [[pipesql-event]] - 키 이벤트 핸들링 (crossterm KeyEvent 처리)
- [[pipesql-ui]] - ratatui 터미널 렌더링 (Block 위젯, 향후 레이아웃 계획)

---

## 사용 크레이트

| 크레이트 | 용도 | 노트 |
|----------|------|------|
| [[rust-crate-tokio]] | 비동기 런타임 | 메인 런타임 |
| [[rust-crate-clap]] | CLI 인자 파싱 | 서버 설정 |
| [[rust-crate-serde]] | 직렬화 | 데이터 교환 |
| `dashmap` | 락프리 HashMap | 동시 접근 핵심 |
| `ratatui` | TUI 프레임워크 | REPL 화면 |
| `crossterm` | 터미널 이벤트 | 키 입력 처리 |
| `rustyline` | 라인 편집 | REPL 입력 |
| `thiserror` | 에러 타입 정의 | [[rust-crate-anyhow]] |

---

## 아키텍처 설계

```
사용자 입력
    ↓
[REPL] → 키 이벤트 처리
    ↓
[SQL 파서] → 토크나이저 → AST (예정)
    ↓
[실행 엔진] → CRUD 처리 (예정)
    ↓
[Storage] → Table/Schema/Value
    ↓
[결과 렌더링] → ratatui 출력
```

---

## 핵심 타입

```rust
// 테이블
pub struct Table {
    pub name: TableName,       // 검증된 테이블 이름
    pub columns: Schema,       // 컬럼 정의
    pub rows: HashMap<u64, Row>, // 행 데이터
}

// 값
pub enum Value {
    Integer(i64),
    Null,
}

// 에러
pub enum TableError {
    Init(String),
    Schema(SchemaError),
}
```

---

## 기존 DB와 비교

| 문제 | 전통 DBMS | PipeSQL 해결책 |
|------|----------|---------------|
| TCP 오버헤드 | MySQL, PostgreSQL | QUIC (멀티플렉싱) |
| 락 경합 | 전통 DBMS | 락프리 (DashMap) |
| 읽기/쓰기 블로킹 | 단순 DB | MVCC |
| 복잡한 설정 | MySQL, PostgreSQL | 제로 설정 |

---

## 개발 로드맵

| 버전 | 단계 | 목표 | 상태 |
|------|------|------|------|
| - | 1단계 | REPL UI + 키보드 이벤트 | 진행 중 |
| - | 2단계 | Storage + 기본 SQL (CREATE/INSERT/SELECT) | 미착수 |
| - | 3단계 | WHERE/UPDATE/DELETE/ORDER BY | 미착수 |
| - | 4단계 | 히스토리, 자동완성, DashMap 통합 | 미착수 |
| v0.1.0 | 1~4 | 완전한 REPL + SQL CRUD | 미착수 |
| v0.2.0 | 5 | QUIC 네트워크 서버 + SDK | 미착수 |
| v0.3.0+ | 6~9 | JOIN, 트랜잭션, 영속성, 배포 | 미착수 |

---

## 관련 Rust 개념

| 개념 | 노트 |
|------|------|
| 소유권과 테이블 구조 | [[rust-ownership]], [[rust-struct]] |
| 에러 처리 패턴 | [[rust-result]], [[rust-crate-anyhow]] |
| 열거형과 패턴 매칭 | [[rust-enum]], [[rust-pattern-matching]] |
| HashMap 활용 | [[rust-hashmap]] |
| 비동기 런타임 | [[rust-async]], [[rust-crate-tokio]] |
| 동시성 (Mutex/Arc) | [[rust-mutex]], [[rust-threads]] |
| 모듈 시스템 | [[rust-modules]] |
| 매크로 (derive) | [[rust-macros]] |

---

## CI/CD

```yaml
# .github/workflows/ci.yml
Lint:  rustfmt + clippy
Test:  Ubuntu, macOS, Windows
Coverage: 50%+ (cargo-llvm-cov)
```

---

## 외부 링크

- [DashMap 문서](https://docs.rs/dashmap/)
- [ratatui 문서](https://docs.rs/ratatui/)
- [QUIC 프로토콜](https://www.chromium.org/quic/)

---

*Zettelkasten 스타일로 구성됨*
