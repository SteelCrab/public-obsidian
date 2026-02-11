# Rust 트레이트

#rust #트레이트 #trait

---

공유 동작을 정의하는 인터페이스. 다형성의 핵심 메커니즘.

## 정의와 구현

```rust
trait Summary {
    fn summarize(&self) -> String;

    // 기본 구현
    fn preview(&self) -> String {
        format!("{}...", &self.summarize()[..20])
    }
}

struct Article {
    title: String,
    content: String,
}

impl Summary for Article {
    fn summarize(&self) -> String {
        format!("{}: {}", self.title, self.content)
    }
}
```

## 매개변수로 트레이트

```rust
// impl Trait 문법 (간결)
fn notify(item: &impl Summary) {
    println!("속보: {}", item.summarize());
}

// 트레이트 바운드 문법 (명시적)
fn notify<T: Summary>(item: &T) {
    println!("속보: {}", item.summarize());
}

// 여러 트레이트
fn display(item: &(impl Summary + std::fmt::Display)) { ... }
fn display<T: Summary + std::fmt::Display>(item: &T) { ... }
```

## 반환 타입으로 트레이트

```rust
fn create_summary() -> impl Summary {
    Article {
        title: String::from("제목"),
        content: String::from("내용"),
    }
}
```

## 자주 쓰는 표준 트레이트

| 트레이트 | 설명 | derive |
|----------|------|--------|
| `Debug` | 디버그 출력 `{:?}` | O |
| `Display` | 사용자 출력 `{}` | X |
| `Clone` | 깊은 복사 `.clone()` | O |
| `Copy` | 암시적 복사 | O |
| `PartialEq` / `Eq` | 동등 비교 `==` | O |
| `PartialOrd` / `Ord` | 순서 비교 `<, >` | O |
| `Hash` | 해시 계산 | O |
| `Default` | 기본값 생성 | O |
| `From` / `Into` | 타입 변환 | X |
| `Iterator` | 반복자 | X |

## derive 매크로

```rust
#[derive(Debug, Clone, PartialEq)]
struct Point {
    x: f64,
    y: f64,
}
```

> [!info] 트레이트 vs 인터페이스
> Rust의 트레이트는 Java 인터페이스와 유사하지만, 기본 구현과 제네릭 바운드 등 더 강력한 기능을 제공한다.
