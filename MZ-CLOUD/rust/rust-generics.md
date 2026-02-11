# Rust 제네릭

#rust #제네릭 #generics

---

타입을 매개변수화하여 코드를 재사용한다.

## 함수 제네릭

```rust
fn largest<T: PartialOrd>(list: &[T]) -> &T {
    let mut largest = &list[0];
    for item in &list[1..] {
        if item > largest {
            largest = item;
        }
    }
    largest
}

let numbers = vec![34, 50, 25, 100];
let result = largest(&numbers);   // 100
```

## 구조체 제네릭

```rust
struct Point<T> {
    x: T,
    y: T,
}

struct MixedPoint<T, U> {
    x: T,
    y: U,
}

let int_point = Point { x: 5, y: 10 };
let float_point = Point { x: 1.0, y: 4.0 };
let mixed = MixedPoint { x: 5, y: 4.0 };
```

## impl 제네릭

```rust
impl<T> Point<T> {
    fn x(&self) -> &T {
        &self.x
    }
}

// 특정 타입에만 구현
impl Point<f64> {
    fn distance(&self) -> f64 {
        (self.x.powi(2) + self.y.powi(2)).sqrt()
    }
}
```

## 열거형 제네릭

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

> [!info] 단형화 (Monomorphization)
> 컴파일러가 제네릭 코드를 구체 타입 코드로 변환한다.
> 런타임 비용 없이 제네릭을 사용할 수 있다 (제로 비용 추상화).
