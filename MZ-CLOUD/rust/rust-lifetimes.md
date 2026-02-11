# Rust 라이프타임

#rust #라이프타임 #lifetime

---

참조가 유효한 범위를 명시한다. 댕글링 참조를 방지한다.

## 기본 문법

```rust
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}
```

`'a`는 "x와 y 중 더 짧은 라이프타임만큼 반환값이 유효하다"는 의미.

## 라이프타임 생략 규칙

컴파일러가 자동으로 라이프타임을 추론하는 3가지 규칙:

1. 각 참조 매개변수에 고유 라이프타임 부여
2. 입력 라이프타임이 하나면 출력에 동일하게 적용
3. `&self` 또는 `&mut self`가 있으면 self의 라이프타임 적용

```rust
// 생략 가능 (규칙 2 적용)
fn first_word(s: &str) -> &str { ... }

// 실제로는 이것과 동일
fn first_word<'a>(s: &'a str) -> &'a str { ... }
```

## 구조체의 라이프타임

```rust
struct Important<'a> {
    part: &'a str,
}

let novel = String::from("Call me Ishmael.");
let i = Important {
    part: &novel[..4],   // novel이 유효한 동안만 사용 가능
};
```

## 정적 라이프타임

```rust
let s: &'static str = "프로그램 전체 수명 동안 유효";
```

> [!tip] 라이프타임 어노테이션
> 라이프타임은 참조의 수명을 변경하지 않는다.
> 컴파일러에게 참조 간의 관계를 알려줄 뿐이다.
