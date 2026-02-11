# Rust 제어 흐름

#rust #제어흐름 #조건문 #반복문

---

조건문과 반복문으로 프로그램 흐름을 제어한다.

## 조건문

```rust
let x = 5;

if x > 0 {
    println!("양수");
} else if x == 0 {
    println!("영");
} else {
    println!("음수");
}

// if 표현식 (삼항 연산자 대체)
let result = if x > 0 { "양수" } else { "음수" };
```

## 반복문

```rust
// loop - 무한 반복
let mut count = 0;
let result = loop {
    count += 1;
    if count == 10 {
        break count * 2;   // break로 값 반환 가능
    }
};

// while
while count > 0 {
    count -= 1;
}

// for - 범위 반복
for i in 0..5 {         // 0, 1, 2, 3, 4
    println!("{}", i);
}

for i in 0..=5 {        // 0, 1, 2, 3, 4, 5 (포함)
    println!("{}", i);
}

// for - 컬렉션 반복
let arr = [10, 20, 30];
for val in arr.iter() {
    println!("{}", val);
}
```

## match (패턴 매칭)

```rust
let x = 3;
match x {
    1 => println!("하나"),
    2 | 3 => println!("둘 또는 셋"),
    4..=10 => println!("4~10"),
    _ => println!("기타"),      // 기본값 (필수)
}
```

> [!info] for와 반복자
> `for`는 `IntoIterator`를 구현한 모든 타입에 사용 가능하다.
> 자세한 내용은 [[rust-iterators]] 참조.
