# Rust 데이터 타입

#rust #타입 #데이터타입

---

Rust는 정적 타입 언어로, 컴파일 시 모든 변수의 타입이 결정된다.

## 스칼라 타입

| 분류 | 타입 | 예시 |
|------|------|------|
| 정수 | `i8, i16, i32, i64, i128, isize` | `let x: i32 = 42` |
| 부호 없는 정수 | `u8, u16, u32, u64, u128, usize` | `let x: u8 = 255` |
| 부동소수점 | `f32, f64` | `let x: f64 = 3.14` |
| 불리언 | `bool` | `let x = true` |
| 문자 | `char` | `let x = '가'` |

## 복합 타입

```rust
// 튜플
let tup: (i32, f64, u8) = (500, 6.4, 1);
let (x, y, z) = tup;       // 구조 분해
let first = tup.0;          // 인덱스 접근

// 배열 (고정 크기)
let arr: [i32; 5] = [1, 2, 3, 4, 5];
let first = arr[0];
let zeros = [0; 5];         // [0, 0, 0, 0, 0]
```

## 타입 변환

```rust
let x: i32 = 42;
let y: f64 = x as f64;      // as로 캐스팅
let z: i64 = i64::from(x);  // From 트레이트
```

> [!warning] 정수 오버플로우
> 디버그 모드에서는 panic, 릴리스 모드에서는 wrapping이 발생한다.
