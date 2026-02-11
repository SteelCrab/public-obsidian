# Rust 에러 전파 (?)

#rust #에러전파 #물음표연산자

---

`?` 연산자로 에러를 호출자에게 전파한다.

## 기본 사용

```rust
use std::fs::File;
use std::io::{self, Read};

fn read_username() -> Result<String, io::Error> {
    let mut file = File::open("username.txt")?;  // Err면 즉시 반환
    let mut s = String::new();
    file.read_to_string(&mut s)?;                // Err면 즉시 반환
    Ok(s)
}
```

## 체이닝

```rust
fn read_username() -> Result<String, io::Error> {
    let mut s = String::new();
    File::open("username.txt")?.read_to_string(&mut s)?;
    Ok(s)
}

// 더 간결하게
fn read_username() -> Result<String, io::Error> {
    std::fs::read_to_string("username.txt")
}
```

## Option에서 ? 사용

```rust
fn last_char(text: &str) -> Option<char> {
    text.lines().last()?.chars().last()
}
```

## main에서 ? 사용

```rust
fn main() -> Result<(), Box<dyn std::error::Error>> {
    let file = File::open("hello.txt")?;
    Ok(())
}
```

## ? 연산자의 동작

```rust
// 이 코드는
let file = File::open("hello.txt")?;

// 이것과 동일하다
let file = match File::open("hello.txt") {
    Ok(f) => f,
    Err(e) => return Err(From::from(e)),  // 자동 타입 변환
};
```

> [!info] From 트레이트 자동 변환
> `?`는 `From` 트레이트를 통해 에러 타입을 자동 변환한다.
> 반환 타입의 에러로 자동 변환되므로 다양한 에러 타입을 하나로 합칠 수 있다.
