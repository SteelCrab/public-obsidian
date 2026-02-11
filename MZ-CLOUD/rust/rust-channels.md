# Rust 채널

#rust #채널 #channel #동시성

---

스레드 간 메시지 전달. "메모리를 공유하지 말고, 메시지를 공유하라."

## 기본 사용

```rust
use std::sync::mpsc;  // multiple producer, single consumer
use std::thread;

let (tx, rx) = mpsc::channel();

thread::spawn(move || {
    tx.send(String::from("hello")).unwrap();
});

let received = rx.recv().unwrap();  // 블로킹 수신
println!("받음: {}", received);
```

## 수신 메서드

| 메서드 | 설명 |
|--------|------|
| `rx.recv()` | 블로킹 수신 (Result 반환) |
| `rx.try_recv()` | 논블로킹 수신 |
| `rx.recv_timeout(dur)` | 타임아웃 수신 |

## 여러 메시지

```rust
let (tx, rx) = mpsc::channel();

thread::spawn(move || {
    let msgs = vec!["hello", "from", "thread"];
    for msg in msgs {
        tx.send(msg.to_string()).unwrap();
    }
});

// 반복자로 수신 (채널 닫힐 때까지)
for received in rx {
    println!("받음: {}", received);
}
```

## 여러 송신자 (clone)

```rust
let (tx, rx) = mpsc::channel();
let tx2 = tx.clone();

thread::spawn(move || {
    tx.send("스레드 1".to_string()).unwrap();
});

thread::spawn(move || {
    tx2.send("스레드 2".to_string()).unwrap();
});

for received in rx {
    println!("{}", received);
}
```

> [!info] 소유권 이전
> `send()`는 값의 소유권을 수신 측으로 이전한다.
> 보낸 후에는 송신 측에서 사용할 수 없다.
