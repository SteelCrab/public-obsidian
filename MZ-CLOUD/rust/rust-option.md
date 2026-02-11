# Rust Option 타입

#rust #option #null안전

---

값이 있거나 없을 수 있는 상황을 표현한다. Rust에는 null이 없다.

## 정의

```rust
enum Option<T> {
    Some(T),   // 값이 있음
    None,      // 값이 없음
}
```

## 기본 사용

```rust
let some_number: Option<i32> = Some(5);
let no_number: Option<i32> = None;

// match로 처리
match some_number {
    Some(n) => println!("값: {}", n),
    None => println!("없음"),
}
```

## 주요 메서드

| 메서드 | 설명 | 예시 |
|--------|------|------|
| `unwrap()` | Some이면 값, None이면 panic | `opt.unwrap()` |
| `unwrap_or(기본값)` | None이면 기본값 | `opt.unwrap_or(0)` |
| `unwrap_or_else(\|\| 표현식)` | None이면 클로저 실행 | `opt.unwrap_or_else(\|\| compute())` |
| `expect("메시지")` | None이면 메시지와 함께 panic | `opt.expect("값 필요")` |
| `is_some()` | Some이면 true | `opt.is_some()` |
| `is_none()` | None이면 true | `opt.is_none()` |
| `map(f)` | Some이면 f 적용 | `opt.map(\|x\| x * 2)` |
| `and_then(f)` | Some이면 f 적용 (체이닝) | `opt.and_then(\|x\| Some(x + 1))` |
| `filter(f)` | 조건 불일치 시 None | `opt.filter(\|x\| *x > 0)` |

## 실전 예시

```rust
fn find_user(id: u32) -> Option<String> {
    if id == 1 {
        Some(String::from("김철수"))
    } else {
        None
    }
}

// 체이닝
let greeting = find_user(1)
    .map(|name| format!("안녕, {}!", name))
    .unwrap_or(String::from("사용자 없음"));
```

> [!warning] unwrap 주의
> 프로덕션 코드에서 `unwrap()`은 피한다. `match`, `if let`, `unwrap_or`를 사용한다.
