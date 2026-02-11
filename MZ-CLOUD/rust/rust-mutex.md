# Rust Mutex

#rust #mutex #동시성

---

여러 스레드에서 공유 데이터에 안전하게 접근한다.

## 기본 사용

```rust
use std::sync::Mutex;

let m = Mutex::new(5);

{
    let mut num = m.lock().unwrap();  // MutexGuard 획득
    *num = 6;
}   // 스코프 종료 시 자동 해제

println!("m = {:?}", m);
```

## 스레드 간 공유 (Arc + Mutex)

```rust
use std::sync::{Arc, Mutex};
use std::thread;

let counter = Arc::new(Mutex::new(0));
let mut handles = vec![];

for _ in 0..10 {
    let counter = Arc::clone(&counter);
    let handle = thread::spawn(move || {
        let mut num = counter.lock().unwrap();
        *num += 1;
    });
    handles.push(handle);
}

for handle in handles {
    handle.join().unwrap();
}

println!("결과: {}", *counter.lock().unwrap());  // 10
```

## Arc vs Rc

| 타입 | 스레드 안전 | 용도 |
|------|-----------|------|
| `Rc<T>` | X | 단일 스레드 참조 카운팅 |
| `Arc<T>` | O | 멀티 스레드 참조 카운팅 |

## RwLock

```rust
use std::sync::RwLock;

let lock = RwLock::new(5);

// 여러 읽기 잠금 동시 가능
let r1 = lock.read().unwrap();
let r2 = lock.read().unwrap();
drop(r1); drop(r2);

// 쓰기 잠금은 배타적
let mut w = lock.write().unwrap();
*w = 6;
```

> [!warning] 데드락
> 두 Mutex를 서로 반대 순서로 잠그면 데드락이 발생한다.
> 항상 같은 순서로 잠금을 획득한다.
