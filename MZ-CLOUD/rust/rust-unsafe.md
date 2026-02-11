# Rust unsafe

#rust #unsafe #저수준

---

컴파일러의 안전성 검사를 우회하는 코드 블록.

## unsafe로 할 수 있는 것

| 기능 | 설명 |
|------|------|
| 원시 포인터 역참조 | `*const T`, `*mut T` |
| unsafe 함수 호출 | `unsafe fn` |
| 가변 정적 변수 접근 | `static mut` |
| unsafe 트레이트 구현 | `unsafe impl` |
| FFI 함수 호출 | 외부 C 함수 등 |

## 원시 포인터

```rust
let mut num = 5;

let r1 = &num as *const i32;      // 불변 원시 포인터
let r2 = &mut num as *mut i32;    // 가변 원시 포인터

unsafe {
    println!("r1: {}", *r1);
    *r2 = 10;
    println!("r2: {}", *r2);
}
```

## FFI (Foreign Function Interface)

```rust
extern "C" {
    fn abs(input: i32) -> i32;
}

fn main() {
    unsafe {
        println!("C abs(-3) = {}", abs(-3));
    }
}
```

## unsafe 함수

```rust
unsafe fn dangerous() {
    // unsafe 코드
}

unsafe {
    dangerous();
}
```

> [!warning] unsafe 사용 원칙
> unsafe는 최소한으로 사용하고, 안전한 추상화로 감싼다.
> unsafe 블록이 있다고 해서 모든 안전 검사가 비활성화되지는 않는다.
> 빌림 규칙 등 다른 검사는 여전히 작동한다.
