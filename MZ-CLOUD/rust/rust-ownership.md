# Rust 소유권

#rust #소유권 #ownership

---

Rust 메모리 안전성의 핵심 개념. 각 값은 하나의 소유자만 가진다.

## 소유권 규칙

1. 각 값은 하나의 소유자(owner)가 있다
2. 한 번에 하나의 소유자만 존재한다
3. 소유자가 스코프를 벗어나면 값이 해제된다

## 이동 (Move)

```rust
let s1 = String::from("hello");
let s2 = s1;           // s1의 소유권이 s2로 이동
// println!("{}", s1);  // 컴파일 에러! s1은 더 이상 유효하지 않음

let x = 5;
let y = x;             // i32는 Copy 트레이트 - 복사됨
println!("{}", x);     // OK! 스택 데이터는 Copy
```

## 클론 (Clone)

```rust
let s1 = String::from("hello");
let s2 = s1.clone();   // 힙 데이터까지 깊은 복사
println!("{} {}", s1, s2);  // 둘 다 유효
```

## 함수와 소유권

```rust
fn takes_ownership(s: String) {
    println!("{}", s);
}   // s가 drop됨

fn gives_ownership() -> String {
    String::from("hello")   // 소유권을 반환
}

let s = String::from("hello");
takes_ownership(s);          // s의 소유권이 함수로 이동
// println!("{}", s);        // 컴파일 에러!

let s2 = gives_ownership();  // 소유권을 받음
```

## Copy 가능한 타입

| 타입 | Copy |
|------|------|
| 정수, 부동소수점, bool, char | O |
| 튜플 (Copy 타입으로만 구성) | O |
| String, Vec, Box | X (Move) |

> [!info] 소유권과 성능
> 소유권 시스템은 런타임 비용이 없다. 컴파일 타임에 검사된다.
