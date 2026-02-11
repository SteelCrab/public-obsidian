# rand - 난수 생성

#rust #rand #난수 #크레이트

---

Rust의 표준 난수 생성 라이브러리.

## 설치

```toml
[dependencies]
rand = "0.8"
```

## 기본 사용

```rust
use rand::Rng;

fn main() {
    let mut rng = rand::thread_rng();

    // 정수 난수
    let n: i32 = rng.gen();                 // 전체 범위
    let n: i32 = rng.gen_range(1..=100);    // 1~100

    // 부동소수점
    let f: f64 = rng.gen();                 // 0.0 ~ 1.0
    let f: f64 = rng.gen_range(0.0..10.0);  // 0.0 ~ 10.0

    // 불리언
    let b: bool = rng.gen();
}
```

## 컬렉션 관련

```rust
use rand::seq::SliceRandom;

let mut v = vec![1, 2, 3, 4, 5];

// 셔플
v.shuffle(&mut rng);

// 랜덤 선택
let choice = v.choose(&mut rng);              // Option<&T>
let choices: Vec<_> = v.choose_multiple(&mut rng, 3).collect();
```

## 분포 (Distribution)

```rust
use rand::distributions::{Alphanumeric, Uniform};

// 균등 분포
let die = Uniform::new_inclusive(1, 6);
let roll: i32 = rng.sample(die);

// 랜덤 문자열
let s: String = (0..10)
    .map(|_| rng.sample(Alphanumeric) as char)
    .collect();
// "aB3kF9mZqR"
```

## 시드 기반 (재현 가능)

```rust
use rand::SeedableRng;
use rand::rngs::StdRng;

let mut rng = StdRng::seed_from_u64(42);
let n: i32 = rng.gen_range(1..=100);  // 항상 같은 값
```

> [!tip] 추천 게임 예제
> `rand`는 Rust Book의 추측 게임 예제에서 처음 사용하게 된다.
