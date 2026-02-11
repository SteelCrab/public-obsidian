# Rust HashMap

#rust #hashmap #컬렉션 #해시맵

---

키-값 쌍을 저장하는 해시 테이블. `std::collections::HashMap`을 사용한다.

## 생성

```rust
use std::collections::HashMap;

// 빈 HashMap
let mut map: HashMap<String, i32> = HashMap::new();

// from 배열
let map = HashMap::from([
    ("blue", 10),
    ("red", 50),
]);

// collect로 생성
let teams = vec!["blue", "red"];
let scores = vec![10, 50];
let map: HashMap<_, _> = teams.into_iter().zip(scores.into_iter()).collect();
```

## 삽입과 접근

```rust
let mut scores = HashMap::new();

// 삽입
scores.insert(String::from("blue"), 10);
scores.insert(String::from("red"), 50);

// 접근
let score = scores.get("blue");           // Option<&V> 반환
let score = scores["blue"];               // 없으면 panic

// 기본값과 함께 접근
let score = scores.get("green").copied().unwrap_or(0);
```

## 삽입 패턴

```rust
let mut map = HashMap::new();

// 키가 없을 때만 삽입
map.entry("blue").or_insert(10);

// 키가 없으면 기본값 계산 후 삽입
map.entry("blue").or_insert_with(|| expensive_computation());

// 기존 값 수정
let count = map.entry("blue").or_insert(0);
*count += 1;
```

## 반복

```rust
let map = HashMap::from([("a", 1), ("b", 2), ("c", 3)]);

// 키-값 반복
for (key, value) in &map {
    println!("{}: {}", key, value);
}

// 키만 반복
for key in map.keys() {
    println!("{}", key);
}

// 값만 반복
for value in map.values() {
    println!("{}", value);
}
```

## 유용한 메서드

| 메서드 | 설명 |
|--------|------|
| `map.insert(k, v)` | 삽입 (기존 값 반환) |
| `map.get(&k)` | 값 조회 (Option) |
| `map.contains_key(&k)` | 키 존재 여부 |
| `map.remove(&k)` | 키 삭제 |
| `map.len()` | 크기 |
| `map.is_empty()` | 비어있는지 확인 |
| `map.entry(k)` | Entry API |
| `map.keys()` | 키 반복자 |
| `map.values()` | 값 반복자 |
| `map.iter()` | (키, 값) 반복자 |

## 실전 예시: 단어 빈도 카운터

```rust
let text = "hello world hello rust world hello";
let mut word_count = HashMap::new();

for word in text.split_whitespace() {
    let count = word_count.entry(word).or_insert(0);
    *count += 1;
}

// {"hello": 3, "world": 2, "rust": 1}
println!("{:?}", word_count);
```

## 소유권

```rust
let key = String::from("blue");
let value = 10;

let mut map = HashMap::new();
map.insert(key, value);
// key는 이동됨 - 이후 사용 불가
// value는 i32이므로 Copy됨

// 참조를 키로 사용하면 소유권 유지
let mut map = HashMap::new();
map.insert(&key, value);  // 빌림
```

> [!tip] Entry API
> `entry().or_insert()`는 "없으면 삽입, 있으면 기존 값 반환" 패턴에 가장 효율적이다.
