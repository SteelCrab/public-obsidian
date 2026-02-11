# Rust 참조와 빌림

#rust #참조 #빌림 #borrowing

---

소유권을 넘기지 않고 값을 참조한다.

## 빌림 규칙

1. 불변 참조(`&T`)는 여러 개 동시에 가능
2. 가변 참조(`&mut T`)는 하나만 가능
3. 불변 참조와 가변 참조는 동시에 존재할 수 없음

## 불변 참조

```rust
fn calculate_length(s: &String) -> usize {
    s.len()
}   // s는 drop되지 않음 (소유권이 없으므로)

let s = String::from("hello");
let len = calculate_length(&s);  // 빌림
println!("{} 길이: {}", s, len); // s 여전히 유효
```

## 가변 참조

```rust
fn append(s: &mut String) {
    s.push_str(" world");
}

let mut s = String::from("hello");
append(&mut s);
println!("{}", s);  // "hello world"
```

## 빌림 규칙 예시

```rust
let mut s = String::from("hello");

let r1 = &s;        // OK
let r2 = &s;        // OK - 불변 참조 여러 개 가능
println!("{} {}", r1, r2);
// r1, r2는 여기서 마지막 사용 (NLL)

let r3 = &mut s;    // OK - 불변 참조가 더 이상 사용되지 않으므로
println!("{}", r3);
```

> [!warning] 댕글링 참조
> Rust 컴파일러는 참조가 데이터보다 오래 살지 않도록 보장한다.
> 댕글링 포인터가 컴파일 타임에 방지된다.
