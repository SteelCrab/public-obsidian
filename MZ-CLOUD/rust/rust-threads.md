# Rust 스레드

#rust #스레드 #동시성

---

`std::thread`로 운영체제 스레드를 생성한다.

## 스레드 생성

```rust
use std::thread;
use std::time::Duration;

let handle = thread::spawn(|| {
    for i in 1..10 {
        println!("스레드: {}", i);
        thread::sleep(Duration::from_millis(1));
    }
});

// 메인 스레드 작업
for i in 1..5 {
    println!("메인: {}", i);
}

handle.join().unwrap();  // 스레드 완료 대기
```

## move 클로저

```rust
let v = vec![1, 2, 3];

let handle = thread::spawn(move || {
    println!("벡터: {:?}", v);  // v의 소유권 이동
});

// println!("{:?}", v);  // 컴파일 에러 - 소유권 이동됨
handle.join().unwrap();
```

## 여러 스레드

```rust
let mut handles = vec![];

for i in 0..5 {
    let handle = thread::spawn(move || {
        println!("스레드 {} 실행", i);
        i * 2
    });
    handles.push(handle);
}

let results: Vec<i32> = handles
    .into_iter()
    .map(|h| h.join().unwrap())
    .collect();
```

> [!info] Send와 Sync
> `Send`: 다른 스레드로 소유권 이동 가능
> `Sync`: 여러 스레드에서 참조 가능
> 대부분의 타입은 자동으로 Send + Sync이다.
