# Rust 반복자 (Iterator)

#rust #반복자 #iterator #iter

---

컬렉션의 요소를 하나씩 처리하는 지연 평가(lazy) 패턴.

## Iterator 트레이트

```rust
trait Iterator {
    type Item;
    fn next(&mut self) -> Option<Self::Item>;
}
```

## 반복자 생성

| 메서드 | 반환 타입 | 설명 |
|--------|----------|------|
| `.iter()` | `&T` | 불변 참조 반복자 |
| `.iter_mut()` | `&mut T` | 가변 참조 반복자 |
| `.into_iter()` | `T` | 소유권 이동 반복자 |

```rust
let v = vec![1, 2, 3];

// iter() - 불변 참조
let sum: i32 = v.iter().sum();     // v 여전히 유효

// into_iter() - 소유권 이동
for val in v.into_iter() {
    println!("{}", val);
}
// v는 이후 사용 불가
```

## 소비 어댑터 (Consuming Adaptors)

반복자를 소비하여 최종 값을 생성한다.

| 메서드 | 설명 | 예시 |
|--------|------|------|
| `sum()` | 합계 | `v.iter().sum::<i32>()` |
| `count()` | 개수 | `v.iter().count()` |
| `collect()` | 컬렉션으로 변환 | `v.iter().collect::<Vec<_>>()` |
| `for_each(f)` | 각 요소에 f 적용 | `v.iter().for_each(\|x\| println!("{}", x))` |
| `any(f)` | 하나라도 true면 true | `v.iter().any(\|x\| *x > 2)` |
| `all(f)` | 모두 true면 true | `v.iter().all(\|x\| *x > 0)` |
| `find(f)` | 첫 번째 일치 | `v.iter().find(\|&&x\| x > 2)` |
| `position(f)` | 첫 번째 인덱스 | `v.iter().position(\|&x\| x == 2)` |
| `min()` / `max()` | 최솟값/최댓값 | `v.iter().max()` |
| `fold(init, f)` | 누적 계산 | `v.iter().fold(0, \|acc, x\| acc + x)` |
| `reduce(f)` | fold와 유사 (초기값 없음) | `v.iter().copied().reduce(\|a, b\| a + b)` |

## 범위 반복자

```rust
// 범위
let sum: i32 = (1..=100).sum();      // 1~100 합계

// enumerate
for (i, val) in v.iter().enumerate() {
    println!("[{}] = {}", i, val);
}

// zip
let names = vec!["a", "b"];
let scores = vec![1, 2];
let pairs: Vec<_> = names.iter().zip(scores.iter()).collect();
```

## 실전 예시

```rust
let numbers = vec![1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

// 짝수만 골라서 제곱한 합계
let result: i32 = numbers.iter()
    .filter(|&&x| x % 2 == 0)
    .map(|&x| x * x)
    .sum();
// 4 + 16 + 36 + 64 + 100 = 220
```

> [!info] 지연 평가
> 반복자 어댑터는 지연 평가된다. `collect()`, `sum()` 등 소비 어댑터를 호출해야 실행된다.

자세한 어댑터: [[rust-iterator-adapters]]
문자열과 반복자: [[rust-string-iter]]
