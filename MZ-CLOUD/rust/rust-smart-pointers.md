# Rust 스마트 포인터

#rust #스마트포인터 #box #rc

---

데이터 소유권과 메모리 관리를 제공하는 포인터 타입.

## Box\<T\>

힙에 데이터를 할당한다.

```rust
let b = Box::new(5);
println!("{}", b);       // 자동 역참조

// 재귀 타입에 필수
enum List {
    Cons(i32, Box<List>),
    Nil,
}
```

## Rc\<T\> (참조 카운팅)

여러 소유자가 하나의 데이터를 공유한다. 단일 스레드 전용.

```rust
use std::rc::Rc;

let a = Rc::new(String::from("hello"));
let b = Rc::clone(&a);     // 참조 카운트 증가
let c = Rc::clone(&a);

println!("카운트: {}", Rc::strong_count(&a));  // 3
```

## RefCell\<T\> (내부 가변성)

불변 참조로도 내부 데이터를 변경할 수 있다. 런타임에 빌림 규칙 검사.

```rust
use std::cell::RefCell;

let data = RefCell::new(vec![1, 2, 3]);

data.borrow_mut().push(4);           // 가변 빌림
println!("{:?}", data.borrow());     // 불변 빌림
```

## 조합: Rc + RefCell

```rust
use std::rc::Rc;
use std::cell::RefCell;

let shared = Rc::new(RefCell::new(0));
let clone1 = Rc::clone(&shared);
let clone2 = Rc::clone(&shared);

*clone1.borrow_mut() += 10;
*clone2.borrow_mut() += 20;
println!("{}", shared.borrow());  // 30
```

## 비교

| 타입 | 소유권 | 빌림 검사 | 스레드 안전 |
|------|--------|----------|-----------|
| `Box<T>` | 단일 | 컴파일 타임 | O |
| `Rc<T>` | 공유 | 컴파일 타임 | X |
| `Arc<T>` | 공유 | 컴파일 타임 | O |
| `RefCell<T>` | 단일 | 런타임 | X |
| `Mutex<T>` | 공유 | 런타임 | O |

> [!warning] RefCell panic
> `RefCell`은 빌림 규칙을 런타임에 검사한다.
> 불변 빌림과 가변 빌림이 동시에 존재하면 panic이 발생한다.
