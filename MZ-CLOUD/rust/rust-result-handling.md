# Rust Result 처리 패턴

#rust #result #에러처리 #패턴

---

Result를 다양한 방법으로 처리하는 패턴.

## match

```rust
use std::fs::File;

let f = File::open("hello.txt");
let file = match f {
    Ok(file) => file,
    Err(e) => panic!("파일 열기 실패: {}", e),
};
```

## 에러 종류별 처리

```rust
use std::io::ErrorKind;

let f = File::open("hello.txt");
let file = match f {
    Ok(file) => file,
    Err(ref e) if e.kind() == ErrorKind::NotFound => {
        File::create("hello.txt").expect("파일 생성 실패")
    },
    Err(e) => panic!("예상치 못한 에러: {}", e),
};
```

## unwrap과 expect

```rust
// unwrap - Err면 panic
let file = File::open("hello.txt").unwrap();

// expect - 메시지와 함께 panic
let file = File::open("hello.txt").expect("hello.txt를 열 수 없음");

// unwrap_or - Err면 기본값
let port: u16 = "8080".parse().unwrap_or(3000);

// unwrap_or_else - Err면 클로저 실행
let file = File::open("hello.txt")
    .unwrap_or_else(|_| File::create("hello.txt").unwrap());
```

## map과 and_then 체이닝

```rust
fn double_parse(s: &str) -> Result<i32, std::num::ParseIntError> {
    s.parse::<i32>().map(|n| n * 2)
}

fn parse_and_add(a: &str, b: &str) -> Result<i32, std::num::ParseIntError> {
    a.parse::<i32>()
        .and_then(|x| b.parse::<i32>().map(|y| x + y))
}
```

## if let과 while let

```rust
if let Ok(file) = File::open("hello.txt") {
    // 성공 시에만 처리
    println!("파일 열림");
}
```

## 커스텀 에러 타입

```rust
use std::fmt;

#[derive(Debug)]
enum AppError {
    IoError(std::io::Error),
    ParseError(std::num::ParseIntError),
    Custom(String),
}

impl fmt::Display for AppError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            AppError::IoError(e) => write!(f, "IO 에러: {}", e),
            AppError::ParseError(e) => write!(f, "파싱 에러: {}", e),
            AppError::Custom(msg) => write!(f, "{}", msg),
        }
    }
}

impl From<std::io::Error> for AppError {
    fn from(e: std::io::Error) -> Self {
        AppError::IoError(e)
    }
}
```

> [!tip] anyhow와 thiserror
> 실전에서는 `anyhow`(애플리케이션)와 `thiserror`(라이브러리)를 사용하면 에러 처리가 간결해진다.
