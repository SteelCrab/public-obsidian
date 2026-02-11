# Rust 설치

#rust #install #rustup

---

rustup을 사용하여 Rust 툴체인을 설치하고 관리한다.

| 명령어 | 설명 |
|--------|------|
| `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \| sh` | Rust 설치 |
| `rustup update` | 최신 버전 업데이트 |
| `rustup self uninstall` | Rust 삭제 |
| `rustc --version` | 컴파일러 버전 확인 |
| `cargo --version` | Cargo 버전 확인 |

## 툴체인 관리

| 명령어 | 설명 |
|--------|------|
| `rustup toolchain list` | 설치된 툴체인 목록 |
| `rustup default stable` | stable 채널 기본 설정 |
| `rustup default nightly` | nightly 채널 기본 설정 |
| `rustup component add rustfmt` | 코드 포매터 추가 |
| `rustup component add clippy` | 린터 추가 |

> [!tip] 설치 후 확인
> `rustc --version`과 `cargo --version`으로 정상 설치를 확인한다.
> PATH에 `~/.cargo/bin`이 포함되어야 한다.
