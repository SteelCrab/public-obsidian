# Rust 에러 테스트 구현

#rust #테스트 #에러테스트 #test

---

Rust에서 에러 상황을 테스트하는 방법.

## 기본 테스트 구조

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}
```

## assert 매크로

| 매크로 | 설명 |
|--------|------|
| `assert!(expr)` | true인지 확인 |
| `assert_eq!(a, b)` | 같은지 확인 |
| `assert_ne!(a, b)` | 다른지 확인 |
| `assert!(expr, "메시지 {}", 값)` | 실패 시 메시지 |

## panic 테스트

```rust
#[test]
#[should_panic]
fn test_panic() {
    panic!("이 테스트는 panic이 발생해야 통과");
}

#[test]
#[should_panic(expected = "인덱스 초과")]
fn test_specific_panic() {
    // "인덱스 초과" 메시지를 포함하는 panic만 통과
    panic!("인덱스 초과: 10");
}
```

## Result 반환 테스트

```rust
#[test]
fn test_with_result() -> Result<(), String> {
    let result = "42".parse::<i32>();
    match result {
        Ok(n) => {
            assert_eq!(n, 42);
            Ok(())
        }
        Err(e) => Err(format!("파싱 실패: {}", e)),
    }
}

// ? 연산자 사용
#[test]
fn test_with_question_mark() -> Result<(), Box<dyn std::error::Error>> {
    let n: i32 = "42".parse()?;
    assert_eq!(n, 42);
    Ok(())
}
```

## 에러 타입 테스트

```rust
#[derive(Debug, PartialEq)]
enum AppError {
    NotFound,
    InvalidInput(String),
}

fn validate(input: &str) -> Result<i32, AppError> {
    if input.is_empty() {
        return Err(AppError::InvalidInput("빈 입력".to_string()));
    }
    input.parse::<i32>().map_err(|_| AppError::InvalidInput(input.to_string()))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_valid_input() {
        assert_eq!(validate("42"), Ok(42));
    }

    #[test]
    fn test_empty_input() {
        assert_eq!(
            validate(""),
            Err(AppError::InvalidInput("빈 입력".to_string()))
        );
    }

    #[test]
    fn test_invalid_input() {
        assert!(validate("abc").is_err());
    }

    #[test]
    fn test_error_variant() {
        match validate("abc") {
            Err(AppError::InvalidInput(_)) => (),  // 예상된 에러
            other => panic!("예상치 못한 결과: {:?}", other),
        }
    }
}
```

## matches! 매크로로 에러 검증

```rust
#[test]
fn test_error_with_matches() {
    let result = validate("abc");
    assert!(matches!(result, Err(AppError::InvalidInput(_))));
}

#[test]
fn test_option_with_matches() {
    let val: Option<i32> = Some(42);
    assert!(matches!(val, Some(x) if x > 0));
}
```

## 테스트 실행 명령어

| 명령어 | 설명 |
|--------|------|
| `cargo test` | 전체 테스트 실행 |
| `cargo test 함수명` | 특정 테스트 실행 |
| `cargo test -- --nocapture` | 출력 표시 |
| `cargo test -- --test-threads=1` | 순차 실행 |
| `cargo test --doc` | 문서 테스트 실행 |
| `cargo test -- --ignored` | #[ignore] 테스트 실행 |

## 테스트 어트리뷰트

```rust
#[test]
fn normal_test() {}

#[test]
#[ignore]
fn slow_test() {}              // cargo test -- --ignored로 실행

#[test]
#[should_panic]
fn panic_test() {}

#[test]
#[should_panic(expected = "메시지")]
fn specific_panic_test() {}
```

> [!tip] 테스트 조직
> - 단위 테스트: `src/` 내 `#[cfg(test)]` 모듈
> - 통합 테스트: `tests/` 디렉토리에 별도 파일
> - 문서 테스트: `///` 코드 블록 내 예제
