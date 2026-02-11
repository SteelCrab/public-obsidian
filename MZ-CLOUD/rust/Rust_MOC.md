# Rust MOC

#rust #MOC #시스템프로그래밍

---

Rust 언어의 핵심 개념과 실전 패턴을 연결하는 허브 노트.

---

## 시작하기

- [[rust-install]] - 설치 (rustup)
- [[rust-cargo-new]] - 프로젝트 생성
- [[rust-cargo-build]] - 빌드와 실행
- [[rust-cargo-toml]] - Cargo.toml 설정
- [[rust-cargo-dependencies]] - 의존성 관리

---

## 기본 문법

- [[rust-variables]] - 변수와 가변성
- [[rust-data-types]] - 데이터 타입
- [[rust-functions]] - 함수
- [[rust-control-flow]] - 제어 흐름
- [[rust-comments]] - 주석과 문서화

---

## 소유권 시스템

- [[rust-ownership]] - 소유권
- [[rust-borrowing]] - 참조와 빌림
- [[rust-lifetimes]] - 라이프타임
- [[rust-slice]] - 슬라이스

---

## 구조체와 열거형

- [[rust-struct]] - 구조체
- [[rust-enum]] - 열거형
- [[rust-pattern-matching]] - 패턴 매칭
- [[rust-option]] - Option 타입
- [[rust-result]] - Result 타입

---

## 컬렉션

- [[rust-vector]] - Vec
- [[rust-string]] - String
- [[rust-hashmap]] - HashMap

---

## 반복자와 클로저

- [[rust-closures]] - 클로저
- [[rust-iterators]] - 반복자 (Iterator)
- [[rust-iterator-adapters]] - 반복자 어댑터
- [[rust-string-iter]] - 문자열과 반복자 조합

---

## 에러 처리

- [[rust-panic]] - panic!
- [[rust-result-handling]] - Result 처리
- [[rust-error-propagation]] - 에러 전파 (?)
- [[rust-error-testing]] - 에러 테스트 구현

---

## 트레이트와 제네릭

- [[rust-traits]] - 트레이트
- [[rust-generics]] - 제네릭
- [[rust-trait-bounds]] - 트레이트 바운드

---

## 동시성

- [[rust-threads]] - 스레드
- [[rust-channels]] - 채널
- [[rust-mutex]] - Mutex
- [[rust-async]] - async/await

---

## 모듈 시스템

- [[rust-modules]] - 모듈, pub, use, 파일 구조

---

## 고급 기능

- [[rust-smart-pointers]] - 스마트 포인터
- [[rust-macros]] - 매크로
- [[rust-unsafe]] - unsafe
- [[rust-cargo-workspace]] - 워크스페이스

---

## 인기 크레이트

- [[rust-crate-serde]] - serde (직렬화/역직렬화)
- [[rust-crate-tokio]] - tokio (비동기 런타임)
- [[rust-crate-reqwest]] - reqwest (HTTP 클라이언트)
- [[rust-crate-clap]] - clap (CLI 인자 파서)
- [[rust-crate-anyhow]] - anyhow & thiserror (에러 처리)
- [[rust-crate-axum]] - axum (웹 프레임워크)
- [[rust-crate-tracing]] - tracing (구조화된 로깅)
- [[rust-crate-sqlx]] - sqlx (비동기 SQL)
- [[rust-crate-rand]] - rand (난수 생성)
- [[rust-crate-regex]] - regex (정규 표현식)
- [[rust-crate-chrono]] - chrono (날짜와 시간)

---

## 프로젝트

- [[PipeSQL_MOC]] - PipeSQL (인메모리 SQL DB)
- [[GlueSQL_MOC]] - GlueSQL (멀티 모델 SQL 엔진 라이브러리)

---

## 빠른 참조

| 상황 | 노트 |
|------|------|
| 처음 시작 | [[rust-install]], [[rust-cargo-new]] |
| 소유권 이해 | [[rust-ownership]], [[rust-borrowing]] |
| 에러 처리 | [[rust-result-handling]], [[rust-error-propagation]] |
| 반복 처리 | [[rust-iterators]], [[rust-iterator-adapters]] |
| 문자열 조합 | [[rust-string-iter]] |
| HashMap 활용 | [[rust-hashmap]] |
| 테스트 작성 | [[rust-error-testing]] |
| 모듈 구성 | [[rust-modules]] |
| 웹 서버 구축 | [[rust-crate-axum]], [[rust-crate-tokio]] |
| JSON 처리 | [[rust-crate-serde]] |
| DB 연동 | [[rust-crate-sqlx]] |

---

## 외부 링크

- [Rust 공식 문서](https://doc.rust-lang.org/book/)
- [Rust by Example](https://doc.rust-lang.org/rust-by-example/)
- [Rust 표준 라이브러리](https://doc.rust-lang.org/std/)
- [crates.io](https://crates.io/)

---

*Zettelkasten 스타일로 구성됨*
