# Rust 슬라이스

#rust #슬라이스 #slice

---

컬렉션의 연속된 일부를 참조한다. 소유권 없이 데이터의 일부를 사용한다.

## 문자열 슬라이스

```rust
let s = String::from("hello world");

let hello = &s[0..5];     // "hello"
let world = &s[6..11];    // "world"
let hello = &s[..5];      // 처음부터
let world = &s[6..];      // 끝까지
let whole = &s[..];       // 전체
```

## &str vs String

| 타입 | 설명 |
|------|------|
| `String` | 힙에 할당된 소유 문자열 |
| `&str` | 문자열 슬라이스 (빌림) |
| `&String` → `&str` | 자동 변환 (Deref 강제) |

```rust
fn first_word(s: &str) -> &str {    // &str을 받으면 유연함
    let bytes = s.as_bytes();
    for (i, &byte) in bytes.iter().enumerate() {
        if byte == b' ' {
            return &s[..i];
        }
    }
    &s[..]
}

let s = String::from("hello world");
let word = first_word(&s);          // String → &str 자동 변환
let word = first_word("hello");     // 리터럴도 가능
```

## 배열 슬라이스

```rust
let a = [1, 2, 3, 4, 5];
let slice = &a[1..3];     // &[i32] 타입, [2, 3]
```

> [!info] 함수 매개변수
> `&String` 대신 `&str`을 매개변수로 사용하면 String과 &str 모두 받을 수 있다.
