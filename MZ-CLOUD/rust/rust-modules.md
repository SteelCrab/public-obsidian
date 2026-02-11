# Rust 모듈 시스템

#rust #모듈 #mod #use

---

코드를 논리적 단위로 구성하고 가시성을 제어한다.

## 모듈 선언

```rust
// src/main.rs 또는 src/lib.rs
mod garden;           // garden.rs 또는 garden/mod.rs 로드
mod garden {          // 인라인 모듈 정의
    pub fn water() {}
}
```

## 파일 구조

```
src/
├── main.rs
├── garden.rs              # mod garden
├── garden/
│   ├── mod.rs             # mod garden (대안 방식)
│   ├── vegetables.rs      # mod vegetables
│   └── fruits.rs          # mod fruits
└── lib.rs
```

```rust
// src/garden.rs (또는 src/garden/mod.rs)
pub mod vegetables;
pub mod fruits;

pub fn water() {
    println!("물주기");
}
```

## 가시성 (pub)

| 키워드 | 설명 |
|--------|------|
| (기본) | 비공개 - 같은 모듈 내에서만 |
| `pub` | 공개 |
| `pub(crate)` | 크레이트 내에서만 공개 |
| `pub(super)` | 부모 모듈에서만 공개 |
| `pub(in path)` | 지정 경로에서만 공개 |

```rust
mod outer {
    pub mod inner {
        pub fn public_fn() {}
        fn private_fn() {}           // inner 내에서만
        pub(crate) fn crate_fn() {}  // 크레이트 내에서만
        pub(super) fn super_fn() {}  // outer에서만
    }
}
```

## use 키워드

```rust
// 절대 경로
use crate::garden::vegetables::Tomato;

// 상대 경로
use self::garden::water;
use super::other_module::func;  // 부모 모듈

// 별칭
use std::collections::HashMap as Map;

// 여러 항목
use std::io::{self, Read, Write};

// 전체 가져오기 (주의해서 사용)
use std::collections::*;

// 재내보내기
pub use crate::garden::vegetables::Tomato;
```

## 경로 종류

| 경로 | 설명 |
|------|------|
| `crate::` | 현재 크레이트 루트 |
| `self::` | 현재 모듈 |
| `super::` | 부모 모듈 |
| `외부크레이트::` | 외부 크레이트 |

## 실전 프로젝트 구조 예시

```
src/
├── main.rs           # use app::Config; fn main() {}
├── lib.rs            # pub mod config; pub mod routes; pub mod db;
├── config.rs         # pub struct Config {}
├── routes/
│   ├── mod.rs        # pub mod users; pub mod posts;
│   ├── users.rs      # pub fn list() {}
│   └── posts.rs      # pub fn create() {}
└── db/
    ├── mod.rs        # pub mod connection; pub mod models;
    ├── connection.rs
    └── models.rs
```

```rust
// src/lib.rs
pub mod config;
pub mod routes;
pub mod db;

// src/main.rs
use my_app::config::Config;
use my_app::routes;

fn main() {
    let config = Config::new();
    routes::users::list();
}
```

> [!tip] 관례
> - 함수는 부모 모듈까지만 use: `use std::io; ... io::stdin()`
> - 구조체/열거형은 전체 경로: `use std::collections::HashMap;`
> - 이름 충돌 시 부모 모듈로 구분하거나 `as`로 별칭 사용
