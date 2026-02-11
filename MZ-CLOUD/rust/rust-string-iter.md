# Rust 문자열과 반복자 조합

#rust #문자열 #반복자 #string #iter

---

반복자를 활용한 문자열 처리와 생성 패턴.

## 문자열 → 반복자

```rust
let s = "hello world";

s.chars()              // 문자 단위 반복자
s.bytes()              // 바이트 단위 반복자
s.split_whitespace()   // 공백 기준 분리
s.split(',')           // 구분자 기준 분리
s.lines()              // 줄 단위 분리
s.char_indices()       // (바이트 인덱스, 문자) 쌍
```

## 반복자 → 문자열 (collect)

```rust
// chars를 모아서 String 생성
let s: String = "hello".chars().collect();

// 필터링 후 문자열 생성
let vowels: String = "hello world"
    .chars()
    .filter(|c| "aeiou".contains(*c))
    .collect();
// "eoo"

// 변환 후 문자열 생성
let upper: String = "hello"
    .chars()
    .map(|c| c.to_uppercase().next().unwrap())
    .collect();
// "HELLO"
```

## 여러 문자열을 하나로 합치기

```rust
let words = vec!["hello", "world", "rust"];

// join (가장 간단)
let sentence = words.join(" ");
// "hello world rust"

// collect로 직접 합치기
let combined: String = words.iter()
    .map(|s| s.to_string())
    .collect::<Vec<_>>()
    .join(", ");
// "hello, world, rust"

// fold로 합치기
let result = words.iter()
    .fold(String::new(), |mut acc, &word| {
        if !acc.is_empty() { acc.push(' '); }
        acc.push_str(word);
        acc
    });
// "hello world rust"

// intersperse (nightly 또는 itertools)
// words.iter().copied().intersperse(" ").collect::<String>()
```

## 숫자 → 문자열 변환

```rust
let numbers = vec![1, 2, 3, 4, 5];

// 숫자를 문자열로 변환하여 결합
let csv: String = numbers.iter()
    .map(|n| n.to_string())
    .collect::<Vec<_>>()
    .join(", ");
// "1, 2, 3, 4, 5"

// format!과 fold
let result = numbers.iter()
    .enumerate()
    .map(|(i, n)| format!("{}번: {}", i + 1, n))
    .collect::<Vec<_>>()
    .join("\n");
```

## 문자열 파싱

```rust
// 쉼표 구분 문자열 → 숫자 벡터
let csv = "1,2,3,4,5";
let nums: Vec<i32> = csv.split(',')
    .map(|s| s.trim().parse().unwrap())
    .collect();
// [1, 2, 3, 4, 5]

// 안전한 파싱 (에러 무시)
let mixed = "1,abc,3,def,5";
let nums: Vec<i32> = mixed.split(',')
    .filter_map(|s| s.trim().parse().ok())
    .collect();
// [1, 3, 5]
```

## 문자 빈도 카운팅

```rust
use std::collections::HashMap;

let text = "hello world";
let freq: HashMap<char, usize> = text.chars()
    .filter(|c| !c.is_whitespace())
    .fold(HashMap::new(), |mut map, c| {
        *map.entry(c).or_insert(0) += 1;
        map
    });
// {'h': 1, 'e': 1, 'l': 3, 'o': 2, ...}
```

## 실전 패턴

```rust
// 카멜케이스 → 스네이크케이스
let camel = "helloWorld";
let snake: String = camel.chars()
    .enumerate()
    .flat_map(|(i, c)| {
        if c.is_uppercase() && i > 0 {
            vec!['_', c.to_lowercase().next().unwrap()]
        } else {
            vec![c]
        }
    })
    .collect();
// "hello_world"

// 문자열 뒤집기
let reversed: String = "hello".chars().rev().collect();
// "olleh"

// 팰린드롬 검사
let s = "racecar";
let is_palindrome = s.chars().eq(s.chars().rev());
// true
```

> [!tip] collect의 힘
> `collect::<String>()`은 `char` 반복자를 문자열로, `collect::<Vec<_>>()`는 벡터로 변환한다.
> 타입 어노테이션으로 원하는 컬렉션 타입을 지정한다.
