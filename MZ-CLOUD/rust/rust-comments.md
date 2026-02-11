# Rust 주석과 문서화

#rust #주석 #문서화

---

코드 주석과 문서 주석을 작성한다.

## 주석 종류

```rust
// 한 줄 주석

/*
   여러 줄 주석
*/

/// 문서 주석 (아이템에 대한 설명)
/// Markdown 문법 지원
fn my_function() {}

//! 모듈/크레이트 전체 문서 주석
//! lib.rs나 mod.rs 상단에 작성
```

## 문서 주석 예시

```rust
/// 두 수를 더한다.
///
/// # Examples
///
/// ```
/// let result = my_crate::add(2, 3);
/// assert_eq!(result, 5);
/// ```
///
/// # Panics
///
/// 오버플로우 시 panic 발생.
pub fn add(a: i32, b: i32) -> i32 {
    a + b
}
```

| 명령어 | 설명 |
|--------|------|
| `cargo doc` | 문서 생성 |
| `cargo doc --open` | 문서 생성 후 브라우저 열기 |
| `cargo test --doc` | 문서 내 코드 예제 테스트 |

> [!tip] doc test
> `///` 안의 코드 블록은 `cargo test`로 자동 테스트된다.
