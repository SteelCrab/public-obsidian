# GlueSQL 멀티 언어 바인딩

#gluesql #rust #wasm #python #바인딩

---

Rust 코어를 JavaScript(WASM)와 Python(PyO3)에서 사용할 수 있는 바인딩.

> 소스: `pkg/rust/`, `pkg/javascript/`, `pkg/python/`

## Rust 패키지 (`gluesql`)

```toml
[dependencies]
gluesql = "0.18"
```

```rust
use gluesql::prelude::*;

let storage = MemoryStorage::default();
let mut glue = Glue::new(storage);

glue.execute("CREATE TABLE t (id INT)").await;
glue.execute("INSERT INTO t VALUES (1)").await;
let result = glue.execute("SELECT * FROM t").await;
```

### 피처 플래그

기본으로 모든 스토리지가 포함된다. 필요한 것만 선택 가능:

```toml
[dependencies]
gluesql = { version = "0.18", default-features = false, features = [
    "gluesql_memory_storage",
    "gluesql-json-storage"
]}
```

---

## JavaScript 바인딩 (`gluesql-js`)

| 항목 | 내용 |
|------|------|
| 패키지 | `gluesql-js` (npm) |
| 타입 | `cdylib` (WASM 모듈) |
| 연동 | `wasm-bindgen` |
| 스토리지 | memory, web, idb, composite |

```javascript
import { Glue } from 'gluesql';

const glue = new Glue();
await glue.execute("CREATE TABLE users (id INT, name TEXT)");
await glue.execute("INSERT INTO users VALUES (1, 'kim')");
const result = await glue.execute("SELECT * FROM users");
```

### 브라우저 스토리지

| 스토리지 | 대상 |
|----------|------|
| `MemoryStorage` | 인메모리 |
| `WebStorage` | localStorage / sessionStorage |
| `IdbStorage` | IndexedDB |

---

## Python 바인딩 (`gluesql-py`)

| 항목 | 내용 |
|------|------|
| 패키지 | `gluesql-py` (PyPI) |
| 타입 | `cdylib` (Python 확장) |
| 연동 | `pyo3` + `pythonize` |
| 런타임 | `tokio` (멀티스레드) |

```python
from gluesql import Glue, MemoryStorage

storage = MemoryStorage()
glue = Glue(storage)

glue.execute("CREATE TABLE users (id INT, name TEXT)")
glue.execute("INSERT INTO users VALUES (1, 'kim')")
result = glue.query("SELECT * FROM users")
```

### Python 스토리지

| 클래스 | 대상 |
|--------|------|
| `PyMemoryStorage` | 인메모리 |
| `PySledStorage` | sled 임베디드 DB |
| `PyJsonStorage` | JSON 파일 |
| `PySharedMemoryStorage` | 공유 메모리 |

---

## 바인딩 비교

| 항목 | Rust | JavaScript | Python |
|------|------|-----------|--------|
| 패키지 | `gluesql` | `gluesql-js` | `gluesql-py` |
| 설치 | `cargo add` | `npm install` | `pip install` |
| 연동 | 네이티브 | wasm-bindgen | pyo3 |
| 스토리지 수 | 14개 전체 | 4개 (브라우저) | 5개 |
| 비동기 | `async/await` | `Promise` | sync 래퍼 |
| 성능 | 최고 | WASM 수준 | FFI 오버헤드 |

## 사용된 Rust 패턴

| 패턴 | 설명 | 관련 노트 |
|------|------|----------|
| 워크스페이스 | 모노레포 구조 | [[rust-cargo-workspace]] |
| 피처 플래그 | 조건부 컴파일 | [[rust-cargo-toml]] |
| FFI | wasm-bindgen, pyo3 | [[rust-unsafe]] |
| 재내보내기 | `pub use` 통합 API | [[rust-modules]] |

> [!info] 확장 가능
> 공식 문서에 따르면 향후 더 많은 언어 바인딩이 추가될 예정이다.
