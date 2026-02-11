# Rust String (문자열)

#rust #문자열 #string

---

Rust에는 두 가지 문자열 타입이 있다: `String`(소유)과 `&str`(빌림).

## 생성

```rust
let s = String::new();                    // 빈 문자열
let s = String::from("hello");           // &str → String
let s = "hello".to_string();             // to_string()
let s = format!("{}-{}", "hello", "world"); // format! 매크로
```

## 수정

| 메서드 | 설명 |
|--------|------|
| `s.push('문자')` | 문자 추가 |
| `s.push_str("문자열")` | 문자열 추가 |
| `s + &s2` | 연결 (s 소유권 이동) |
| `s.insert(인덱스, '문자')` | 위치에 문자 삽입 |
| `s.insert_str(인덱스, "문자열")` | 위치에 문자열 삽입 |
| `s.replace("old", "new")` | 치환 |
| `s.trim()` | 양쪽 공백 제거 |
| `s.to_uppercase()` | 대문자 변환 |
| `s.to_lowercase()` | 소문자 변환 |

## 문자열 결합

```rust
// format! 매크로 (소유권 이동 없음, 권장)
let s = format!("{} {}", "hello", "world");

// + 연산자 (왼쪽 소유권 이동)
let s1 = String::from("hello");
let s2 = String::from(" world");
let s3 = s1 + &s2;     // s1은 이후 사용 불가

// push_str
let mut s = String::from("hello");
s.push_str(" world");
```

## 문자열 순회

```rust
let s = "안녕하세요";

// 문자 단위
for c in s.chars() {
    println!("{}", c);   // '안', '녕', '하', '세', '요'
}

// 바이트 단위
for b in s.bytes() {
    println!("{}", b);
}

// 문자 인덱스 접근 (직접 인덱싱 불가)
let c: char = s.chars().nth(2).unwrap();  // '하'
```

## 슬라이싱

```rust
let hello = &s[0..9];   // 바이트 인덱스 기준 (UTF-8 경계에 주의)
```

> [!warning] UTF-8 인덱싱
> Rust의 String은 UTF-8이므로 `s[0]` 같은 직접 인덱싱이 불가능하다.
> `chars()`, `bytes()`, 또는 바이트 범위 슬라이싱을 사용한다.

> [!info] 반복자를 이용한 문자열 생성
> 자세한 내용은 [[rust-string-iter]] 참조.
