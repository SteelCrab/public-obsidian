# Rust 트레이트 바운드

#rust #트레이트바운드 #제네릭

---

제네릭 타입에 특정 트레이트 구현을 요구한다.

## 기본 문법

```rust
// 간결한 문법
fn print_it(item: &impl std::fmt::Display) {
    println!("{}", item);
}

// 트레이트 바운드 문법
fn print_it<T: std::fmt::Display>(item: &T) {
    println!("{}", item);
}
```

## 복수 바운드

```rust
fn compare_and_display<T: PartialOrd + std::fmt::Display>(a: &T, b: &T) {
    if a > b {
        println!("{} > {}", a, b);
    }
}
```

## where 절

바운드가 복잡할 때 가독성을 높인다.

```rust
fn process<T, U>(t: &T, u: &U) -> String
where
    T: std::fmt::Display + Clone,
    U: std::fmt::Debug + PartialOrd,
{
    format!("{}: {:?}", t, u)
}
```

## 조건부 구현

```rust
struct Pair<T> {
    x: T,
    y: T,
}

// 모든 T에 대해
impl<T> Pair<T> {
    fn new(x: T, y: T) -> Self {
        Self { x, y }
    }
}

// Display + PartialOrd인 T에만
impl<T: std::fmt::Display + PartialOrd> Pair<T> {
    fn cmp_display(&self) {
        if self.x >= self.y {
            println!("최대: {}", self.x);
        } else {
            println!("최대: {}", self.y);
        }
    }
}
```

> [!info] 블랭킷 구현
> 표준 라이브러리의 `impl<T: Display> ToString for T`처럼
> 트레이트 바운드를 만족하는 모든 타입에 자동으로 구현을 제공할 수 있다.
