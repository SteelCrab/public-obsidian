# Rust 구조체

#rust #구조체 #struct

---

관련 데이터를 하나로 묶는 사용자 정의 타입.

## 정의와 생성

```rust
struct User {
    username: String,
    email: String,
    active: bool,
    sign_in_count: u64,
}

let user = User {
    username: String::from("kim"),
    email: String::from("kim@example.com"),
    active: true,
    sign_in_count: 1,
};
```

## 축약 문법

```rust
fn build_user(email: String, username: String) -> User {
    User {
        email,           // 필드 축약 (변수명과 같을 때)
        username,
        active: true,
        sign_in_count: 1,
    }
}

// 구조체 업데이트 문법
let user2 = User {
    email: String::from("new@example.com"),
    ..user               // 나머지는 user에서 가져옴
};
```

## 튜플 구조체와 유닛 구조체

```rust
struct Color(i32, i32, i32);      // 튜플 구조체
struct Point(f64, f64, f64);
let black = Color(0, 0, 0);

struct AlwaysEqual;                // 유닛 구조체
```

## 메서드 (impl)

```rust
struct Rectangle {
    width: f64,
    height: f64,
}

impl Rectangle {
    // 메서드 (&self)
    fn area(&self) -> f64 {
        self.width * self.height
    }

    // 연관 함수 (생성자 패턴)
    fn square(size: f64) -> Self {
        Self { width: size, height: size }
    }
}

let rect = Rectangle::square(5.0);
println!("넓이: {}", rect.area());
```

> [!info] derive 매크로
> `#[derive(Debug, Clone, PartialEq)]`로 일반적인 트레이트를 자동 구현할 수 있다.
