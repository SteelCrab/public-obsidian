# Rust 클로저

#rust #클로저 #closure

---

환경을 캡처할 수 있는 익명 함수.

## 기본 문법

```rust
let add = |x, y| x + y;
let result = add(1, 2);          // 3

let add_one = |x: i32| -> i32 { x + 1 };  // 타입 명시

// 여러 줄
let process = |x| {
    let doubled = x * 2;
    doubled + 1
};
```

## 환경 캡처

```rust
let name = String::from("Rust");

// 불변 빌림 (Fn)
let greet = || println!("Hello, {}", name);
greet();
println!("{}", name);    // OK - 불변 빌림

// 가변 빌림 (FnMut)
let mut count = 0;
let mut increment = || count += 1;
increment();

// 소유권 이동 (FnOnce)
let name = String::from("Rust");
let consume = move || println!("Hello, {}", name);
consume();
// println!("{}", name);  // 컴파일 에러 - 소유권 이동됨
```

## 클로저 트레이트

| 트레이트 | 캡처 방식 | 설명 |
|----------|----------|------|
| `Fn` | `&self` | 불변 빌림, 여러 번 호출 가능 |
| `FnMut` | `&mut self` | 가변 빌림, 여러 번 호출 가능 |
| `FnOnce` | `self` | 소유권 이동, 한 번만 호출 가능 |

## 함수 매개변수로 클로저

```rust
fn apply<F: Fn(i32) -> i32>(f: F, x: i32) -> i32 {
    f(x)
}

let double = |x| x * 2;
let result = apply(double, 5);   // 10
```

## 클로저 반환

```rust
fn make_adder(n: i32) -> impl Fn(i32) -> i32 {
    move |x| x + n
}

let add5 = make_adder(5);
println!("{}", add5(3));  // 8
```

> [!info] move 키워드
> `move`를 사용하면 클로저가 캡처하는 모든 변수의 소유권을 가져간다.
> 스레드에 클로저를 전달할 때 자주 사용된다.
