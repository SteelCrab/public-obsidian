# regex - 정규 표현식

#rust #regex #정규표현식 #크레이트

---

Rust의 정규표현식 라이브러리. 안전하고 빠른 UTF-8 문자열 매칭.

## 설치

```toml
[dependencies]
regex = "1"
```

## 기본 사용

```rust
use regex::Regex;

let re = Regex::new(r"\d{3}-\d{4}-\d{4}").unwrap();

// 매칭 확인
let is_phone = re.is_match("010-1234-5678");  // true

// 첫 번째 매칭 찾기
if let Some(m) = re.find("전화: 010-1234-5678") {
    println!("찾음: {}", m.as_str());   // "010-1234-5678"
    println!("위치: {}..{}", m.start(), m.end());
}

// 모든 매칭
for m in re.find_iter("010-1111-2222, 010-3333-4444") {
    println!("{}", m.as_str());
}
```

## 캡처 그룹

```rust
let re = Regex::new(r"(\d{4})-(\d{2})-(\d{2})").unwrap();

if let Some(caps) = re.captures("날짜: 2024-01-15") {
    println!("전체: {}", &caps[0]);   // "2024-01-15"
    println!("년: {}", &caps[1]);     // "2024"
    println!("월: {}", &caps[2]);     // "01"
    println!("일: {}", &caps[3]);     // "15"
}

// 이름 있는 캡처 그룹
let re = Regex::new(r"(?P<year>\d{4})-(?P<month>\d{2})-(?P<day>\d{2})").unwrap();
if let Some(caps) = re.captures("2024-01-15") {
    println!("년: {}", &caps["year"]);
}
```

## 치환

```rust
let re = Regex::new(r"\d+").unwrap();

// 전체 치환
let result = re.replace_all("abc123def456", "NUM");
// "abcNUMdefNUM"

// 캡처 그룹 참조
let re = Regex::new(r"(\w+)@(\w+)\.(\w+)").unwrap();
let result = re.replace("kim@example.com", "$1 at $2");
// "kim at example"
```

## 분할

```rust
let re = Regex::new(r"[,;\s]+").unwrap();
let parts: Vec<&str> = re.split("a, b; c  d").collect();
// ["a", "b", "c", "d"]
```

## 성능 최적화

```rust
use std::sync::LazyLock;

// 정적 컴파일 (한 번만 생성)
static RE: LazyLock<Regex> = LazyLock::new(|| {
    Regex::new(r"\d+").unwrap()
});

fn find_numbers(text: &str) -> Vec<&str> {
    RE.find_iter(text).map(|m| m.as_str()).collect()
}
```

> [!tip] RegexSet
> 여러 패턴을 동시에 매칭할 때 `RegexSet`을 사용하면 효율적이다.
