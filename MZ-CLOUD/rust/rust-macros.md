# Rust 매크로

#rust #매크로 #macro

---

코드를 생성하는 코드. 메타프로그래밍 도구.

## 자주 쓰는 내장 매크로

| 매크로 | 설명 |
|--------|------|
| `println!("{}",x)` | 표준 출력 |
| `format!("{}-{}",a,b)` | 문자열 생성 |
| `vec![1,2,3]` | 벡터 생성 |
| `assert_eq!(a,b)` | 동등 검증 |
| `todo!()` | 미구현 표시 (panic) |
| `unimplemented!()` | 미구현 표시 (panic) |
| `dbg!(expr)` | 디버그 출력 |
| `include_str!("파일")` | 파일 내용을 문자열로 |
| `cfg!(조건)` | 조건부 컴파일 검사 |

## 선언적 매크로 (macro_rules!)

```rust
macro_rules! say_hello {
    () => {
        println!("Hello!");
    };
    ($name:expr) => {
        println!("Hello, {}!", $name);
    };
}

say_hello!();              // "Hello!"
say_hello!("Rust");        // "Hello, Rust!"
```

## 매크로 패턴

```rust
macro_rules! create_map {
    ($($key:expr => $val:expr),* $(,)?) => {{
        let mut map = std::collections::HashMap::new();
        $(map.insert($key, $val);)*
        map
    }};
}

let scores = create_map! {
    "alice" => 100,
    "bob" => 85,
};
```

## derive 매크로

```rust
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct User {
    name: String,
    age: u32,
}
```

## 주요 derive 트레이트

| derive | 기능 |
|--------|------|
| `Debug` | `{:?}` 포맷 출력 |
| `Clone` | `.clone()` 메서드 |
| `Copy` | 암시적 복사 |
| `PartialEq` | `==` 비교 |
| `Hash` | HashMap 키로 사용 |
| `Default` | 기본값 생성 |
| `Serialize` / `Deserialize` | serde 직렬화 |

> [!info] 매크로 vs 함수
> 매크로는 컴파일 타임에 코드를 생성한다.
> 가변 인자, 코드 생성 등 함수로 불가능한 작업이 가능하다.
