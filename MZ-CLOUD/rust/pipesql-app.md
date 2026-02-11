# PipeSQL App 상태 관리

#pipesql #rust #repl #app

---

REPL 애플리케이션의 상태와 메인 이벤트 루프를 관리한다.

> 소스: `src/repl/app.rs`

## 구조체 정의

```rust
pub struct App {
    running: bool,
}
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `running` | `bool` | 앱 실행 상태 (true = 실행 중) |

## 메서드

| 메서드 | 반환 | 설명 |
|--------|------|------|
| `App::new()` | `Self` | `running: true`로 생성 |
| `.is_running()` | `bool` | 실행 상태 확인 |
| `.run()` | `io::Result<()>` | 터미널 초기화 + 루프 실행 + 정리 |
| `.quit()` | `()` | `running = false`로 종료 |

## 메인 루프 (핵심)

```rust
pub fn run(&mut self) -> io::Result<()> {
    let mut terminal = ratatui::init();      // 1. 터미널 초기화
    let result = self.run_loop(&mut terminal); // 2. 이벤트 루프
    ratatui::restore();                       // 3. 터미널 복원
    result
}

fn run_loop(&mut self, terminal: &mut DefaultTerminal) -> io::Result<()> {
    while self.running {
        terminal.draw(ui::render)?;           // UI 렌더링
        if let Event::Key(key) = event::read()? {  // 키 이벤트 대기
            handle_key(self, key);            // 키 처리
        }
    }
    Ok(())
}
```

### 실행 흐름

```
App::new() → running: true
    ↓
App::run()
    ├── ratatui::init()          터미널 raw 모드 진입
    ├── run_loop()
    │     ├── draw(ui::render)   화면 렌더링
    │     ├── event::read()      블로킹 키 입력 대기
    │     ├── handle_key()       키 처리 (ESC → quit)
    │     └── while running      루프 반복
    └── ratatui::restore()       터미널 원래 모드 복원
```

## Default 트레이트 구현

```rust
impl Default for App {
    fn default() -> Self {
        Self::new()
    }
}
```

`Default`를 구현하여 `App::default()`로도 생성 가능하다.

## 진입점 (main.rs)

```rust
#[tokio::main]
async fn main() -> Result<(), ArgsError> {
    if let Err(e) = App::new().run() {
        eprintln!("Error: {}", e);
    }
    Ok(())
}
```

`tokio::main`으로 비동기 런타임을 시작하지만, 현재 `App::run()`은 동기 코드이다.

## 테스트

```rust
#[test]
fn test_repl_app_new() {
    let app = App::new();
    assert!(app.is_running());
}

#[test]
fn test_repl_app_default() {
    let default = App::default();
    assert!(default.is_running());
}

#[test]
fn test_repl_app_quit() {
    let mut app = App::new();
    app.quit();
    assert!(!app.running);
}
```

## 사용된 Rust 패턴

| 패턴 | 설명 | 관련 노트 |
|------|------|----------|
| 구조체 + impl | 상태와 동작 캡슐화 | [[rust-struct]] |
| Default 트레이트 | 기본 생성자 제공 | [[rust-traits]] |
| io::Result | 표준 I/O 에러 처리 | [[rust-result]] |
| if let | `Event::Key(key)` 패턴 매칭 | [[rust-pattern-matching]] |
| ? 연산자 | `terminal.draw()?`, `event::read()?` | [[rust-error-propagation]] |
| 가변 참조 | `&mut self`, `&mut terminal` | [[rust-borrowing]] |

## 모듈 공개 구조

```rust
// src/repl/mod.rs
mod app;
mod event;
mod ui;
pub use app::App;   // App만 외부에 공개
```

`event`와 `ui`는 비공개 모듈이다. 외부에서는 `App`만 접근 가능하다.

> [!info] 향후 확장
> SQL 입력 버퍼, 커서 위치, 결과 출력 영역, 히스토리 등의 상태가 `App`에 추가될 예정이다.
