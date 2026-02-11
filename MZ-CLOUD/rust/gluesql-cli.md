# GlueSQL CLI

#gluesql #rust #cli #repl

---

대화형 SQL REPL과 파일 실행, 덤프 기능을 제공하는 CLI 도구.

> 소스: `cli/src/`

## 설치와 실행

```bash
cargo install gluesql-cli
gluesql                          # 기본 (메모리 스토리지)
gluesql --storage sled --path ./data   # sled 스토리지
```

## CLI 옵션

| 옵션 | 설명 |
|------|------|
| `--storage <TYPE>` | 스토리지 선택 (memory, sled, redb, json, csv, parquet, file) |
| `--path <PATH>` | 스토리지 경로 |
| `--execute <FILE>` | SQL 파일 실행 |
| `--dump <PATH>` | 데이터베이스를 SQL로 덤프 |

## 소스 구조

| 파일 | 역할 |
|------|------|
| `main.rs` | 진입점 (`gluesql_cli::run()`) |
| `lib.rs` | Args 파싱 + 메인 로직 |
| `cli.rs` | REPL 구현 (rustyline) |
| `command.rs` | 명령어 파싱 |
| `print.rs` | 결과 테이블 포맷 출력 (tabled) |
| `helper.rs` | CLI 헬퍼 함수 |

## 주요 의존성

| 크레이트 | 용도 |
|----------|------|
| `clap` | CLI 인자 파싱 |
| `rustyline` | 대화형 라인 편집 |
| `tabled` | 테이블 형식 출력 |
| 모든 스토리지 | 다중 백엔드 지원 |

## 사용 예시

```
gluesql> CREATE TABLE users (id INT, name TEXT);
Table created

gluesql> INSERT INTO users VALUES (1, 'kim'), (2, 'lee');
2 rows inserted

gluesql> SELECT * FROM users;
+----+------+
| id | name |
+----+------+
|  1 | kim  |
|  2 | lee  |
+----+------+
```

## 사용된 Rust 패턴

| 패턴 | 설명 | 관련 노트 |
|------|------|----------|
| clap derive | `#[derive(Parser)]` | [[rust-crate-clap]] |
| async 메인 | `#[tokio::main]` | [[rust-async]] |
| 다형성 | 스토리지 타입별 분기 | [[rust-enum]] |

> [!info] PipeSQL과 비교
> GlueSQL CLI는 rustyline 기반 텍스트 REPL이고,
> PipeSQL은 ratatui 기반 TUI REPL을 지향한다.
