# Rust 패턴 매칭

#rust #패턴매칭 #match

---

`match`와 `if let`으로 값의 구조에 따라 분기한다.

## match

```rust
enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter(String),
}

fn value(coin: &Coin) -> u32 {
    match coin {
        Coin::Penny => 1,
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter(state) => {
            println!("{}주 쿼터", state);
            25
        }
    }
}
```

## 패턴 종류

```rust
let x = 5;
match x {
    1 => println!("하나"),
    2 | 3 => println!("2 또는 3"),      // OR 패턴
    4..=9 => println!("4~9"),           // 범위 패턴
    n @ 10..=20 => println!("{}", n),   // 바인딩
    _ => println!("기타"),               // 와일드카드
}
```

## if let (간단한 매칭)

```rust
let val: Option<i32> = Some(42);

// match 대신 간결하게
if let Some(x) = val {
    println!("값: {}", x);
}

// else 포함
if let Some(x) = val {
    println!("{}", x);
} else {
    println!("없음");
}
```

## while let

```rust
let mut stack = vec![1, 2, 3];
while let Some(top) = stack.pop() {
    println!("{}", top);
}
```

## 구조 분해

```rust
struct Point { x: i32, y: i32 }

let p = Point { x: 0, y: 7 };
let Point { x, y } = p;

match p {
    Point { x: 0, y } => println!("x축 위: y={}", y),
    Point { x, y: 0 } => println!("y축 위: x={}", x),
    Point { x, y } => println!("({}, {})", x, y),
}
```

> [!warning] match는 완전해야 한다
> 모든 가능한 값을 처리해야 한다. `_` 와일드카드로 나머지를 처리한다.
