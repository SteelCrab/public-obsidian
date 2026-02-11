# Rust Result 타입

#rust #result #에러처리

---

성공 또는 실패를 표현한다. 에러 처리의 핵심 타입.

## 정의

```rust
enum Result<T, E> {
    Ok(T),    // 성공
    Err(E),   // 실패
}
```

## 기본 사용

```rust
use std::fs::File;

let f = File::open("hello.txt");

match f {
    Ok(file) => println!("파일 열기 성공"),
    Err(error) => println!("에러: {}", error),
}
```

## 주요 메서드

| 메서드 | 설명 |
|--------|------|
| `unwrap()` | Ok면 값, Err면 panic |
| `expect("msg")` | Ok면 값, Err면 메시지와 panic |
| `unwrap_or(기본값)` | Err면 기본값 |
| `is_ok()` | 성공 여부 |
| `is_err()` | 실패 여부 |
| `map(f)` | Ok값에 f 적용 |
| `map_err(f)` | Err값에 f 적용 |
| `and_then(f)` | Ok면 f 적용 (체이닝) |
| `or_else(f)` | Err면 f 적용 |

## ? 연산자 (에러 전파)

```rust
fn read_username() -> Result<String, std::io::Error> {
    let mut s = String::new();
    File::open("user.txt")?.read_to_string(&mut s)?;
    Ok(s)
}
```

자세한 내용: [[rust-error-propagation]]

> [!info] Result vs Option
> `Option`: 값이 있거나 없음 (에러 정보 불필요)
> `Result`: 성공/실패 + 에러 정보 포함
