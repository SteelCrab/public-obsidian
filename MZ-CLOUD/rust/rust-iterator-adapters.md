# Rust 반복자 어댑터

#rust #반복자 #어댑터 #iterator

---

반복자를 변환하여 새로운 반복자를 생성한다. 체이닝하여 데이터 파이프라인을 구성한다.

## 주요 어댑터

| 어댑터 | 설명 | 예시 |
|--------|------|------|
| `map(f)` | 각 요소를 변환 | `.map(\|x\| x * 2)` |
| `filter(f)` | 조건에 맞는 요소만 | `.filter(\|x\| **x > 3)` |
| `filter_map(f)` | 변환 + None 제거 | `.filter_map(\|x\| x.parse().ok())` |
| `flat_map(f)` | map + flatten | `.flat_map(\|x\| x.chars())` |
| `flatten()` | 중첩 반복자 펼치기 | `vec![vec![1], vec![2]].into_iter().flatten()` |
| `take(n)` | 앞에서 n개만 | `.take(3)` |
| `skip(n)` | 앞에서 n개 건너뜀 | `.skip(2)` |
| `take_while(f)` | 조건 동안만 | `.take_while(\|x\| **x < 5)` |
| `skip_while(f)` | 조건 동안 건너뜀 | `.skip_while(\|x\| **x < 3)` |
| `enumerate()` | (인덱스, 값) 쌍 | `.enumerate()` |
| `zip(iter)` | 두 반복자 합치기 | `.zip(other.iter())` |
| `chain(iter)` | 두 반복자 이어붙이기 | `.chain(other.iter())` |
| `peekable()` | 다음 값 미리보기 | `.peekable()` |
| `rev()` | 역순 | `.rev()` |
| `cloned()` | &T → T (Clone) | `.cloned()` |
| `copied()` | &T → T (Copy) | `.copied()` |
| `inspect(f)` | 디버그 출력 (값 유지) | `.inspect(\|x\| println!("{:?}", x))` |

## 체이닝 예시

```rust
let data = vec![
    "hello world",
    "rust programming",
    "iterator pattern",
];

// 각 문자열의 첫 단어만 대문자로 변환
let result: Vec<String> = data.iter()
    .map(|s| s.split_whitespace().next().unwrap())
    .map(|s| s.to_uppercase())
    .collect();
// ["HELLO", "RUST", "ITERATOR"]
```

## filter_map 활용

```rust
let strings = vec!["42", "abc", "7", "def", "100"];

// 숫자로 변환 가능한 것만 추출
let numbers: Vec<i32> = strings.iter()
    .filter_map(|s| s.parse().ok())
    .collect();
// [42, 7, 100]
```

## flat_map 활용

```rust
let sentences = vec!["hello world", "foo bar"];

let words: Vec<&str> = sentences.iter()
    .flat_map(|s| s.split_whitespace())
    .collect();
// ["hello", "world", "foo", "bar"]
```

## fold 활용

```rust
let numbers = vec![1, 2, 3, 4, 5];

// 합계
let sum = numbers.iter().fold(0, |acc, &x| acc + x);

// 최댓값 (수동)
let max = numbers.iter().fold(i32::MIN, |acc, &x| acc.max(x));

// 문자열 결합
let csv = numbers.iter()
    .map(|x| x.to_string())
    .collect::<Vec<_>>()
    .join(", ");
// "1, 2, 3, 4, 5"
```

## window와 chunks

```rust
let data = vec![1, 2, 3, 4, 5];

// 슬라이딩 윈도우
for window in data.windows(3) {
    println!("{:?}", window);  // [1,2,3], [2,3,4], [3,4,5]
}

// 청크 분할
for chunk in data.chunks(2) {
    println!("{:?}", chunk);   // [1,2], [3,4], [5]
}
```

> [!tip] 성능
> 반복자 체인은 컴파일러가 최적화하여 수동 루프와 동등한 성능을 낸다 (제로 비용 추상화).
