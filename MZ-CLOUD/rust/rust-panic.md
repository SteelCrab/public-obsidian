# Rust panic!

#rust #panic #에러처리

---

복구 불가능한 에러가 발생하면 프로그램을 종료한다.

## panic! 매크로

```rust
panic!("치명적 에러 발생!");
panic!("인덱스 {} 초과", 10);
```

## panic이 발생하는 상황

| 상황 | 예시 |
|------|------|
| 명시적 호출 | `panic!("에러")` |
| 배열 범위 초과 | `v[100]` |
| unwrap 실패 | `None.unwrap()` |
| 정수 오버플로우 (디버그) | `let x: u8 = 255 + 1` |

## 환경 변수로 백트레이스 확인

```bash
RUST_BACKTRACE=1 cargo run     # 간단한 백트레이스
RUST_BACKTRACE=full cargo run  # 전체 백트레이스
```

## panic vs Result

| 사용 | 상황 |
|------|------|
| `panic!` | 프로그래밍 에러, 복구 불가능 |
| `Result` | 예상 가능한 실패, 복구 가능 |

> [!warning] 라이브러리에서 panic
> 라이브러리 코드에서는 panic 대신 `Result`를 반환하여 호출자가 처리하도록 한다.
