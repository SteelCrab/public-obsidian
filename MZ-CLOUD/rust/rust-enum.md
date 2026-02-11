# Rust 열거형

#rust #열거형 #enum

---

가능한 값의 집합을 정의한다. 각 변형(variant)에 데이터를 포함할 수 있다.

## 기본 열거형

```rust
enum Direction {
    Up,
    Down,
    Left,
    Right,
}

let d = Direction::Up;
```

## 데이터를 가진 열거형

```rust
enum Message {
    Quit,                        // 데이터 없음
    Move { x: i32, y: i32 },    // 구조체 형태
    Write(String),               // String 포함
    ChangeColor(i32, i32, i32),  // 튜플 형태
}

let msg = Message::Write(String::from("hello"));
```

## impl로 메서드 추가

```rust
impl Message {
    fn call(&self) {
        match self {
            Message::Write(text) => println!("{}", text),
            Message::Quit => println!("종료"),
            _ => println!("기타"),
        }
    }
}
```

## Option과 Result

Rust에는 null이 없다. 대신 `Option`과 `Result`를 사용한다.

```rust
enum Option<T> {
    Some(T),
    None,
}

enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

자세한 내용: [[rust-option]], [[rust-result]]

> [!info] enum의 크기
> enum의 크기는 가장 큰 variant + 태그(discriminant) 크기이다.
