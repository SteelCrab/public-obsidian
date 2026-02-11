# PipeSQL 키 이벤트 처리

#pipesql #rust #repl #event

---

키보드 입력을 처리하는 이벤트 핸들러.

> 소스: `src/repl/event.rs`

## 핸들러 함수

```rust
use super::App;
use crossterm::event::{KeyCode, KeyEvent};

pub fn handle_key(app: &mut App, key: KeyEvent) {
    if key.code == KeyCode::Esc {
        app.quit()
    }
}
```

| 키 | 동작 |
|----|------|
| `ESC` | `app.quit()` → 앱 종료 |
| 나머지 | 무시 (no-op) |

## 호출 흐름

```
crossterm::event::read()       블로킹 이벤트 읽기
    ↓
Event::Key(key)                키 이벤트 분기
    ↓
handle_key(app, key)           핸들러 호출
    ↓
key.code == KeyCode::Esc?
    ├── Yes → app.quit()       running = false
    └── No  → (아무 것도 안 함)
```

## crossterm 이벤트 타입

```rust
// crossterm에서 제공하는 주요 타입
pub struct KeyEvent {
    pub code: KeyCode,
    pub modifiers: KeyModifiers,
    pub kind: KeyEventKind,
    pub state: KeyEventState,
}

pub enum KeyCode {
    Char(char),
    Enter,
    Esc,
    Backspace,
    Tab,
    Up, Down, Left, Right,
    // ...
}
```

## 테스트

```rust
#[test]
fn test_handle_key_exit() {
    let mut app = App::new();
    handle_key(&mut app, KeyEvent::from(KeyCode::Esc));
    assert!(!app.is_running());
}

#[test]
fn test_handle_key_others() {
    let mut app = App::new();
    handle_key(&mut app, KeyEvent::from(KeyCode::Char('c')));
    assert!(app.is_running());
}
```

`KeyEvent::from(KeyCode::Esc)` - crossterm의 `From` 트레이트로 간단히 테스트 이벤트를 생성한다.

## 사용된 Rust 패턴

| 패턴 | 설명 | 관련 노트 |
|------|------|----------|
| 가변 참조 매개변수 | `app: &mut App` | [[rust-borrowing]] |
| 열거형 비교 | `key.code == KeyCode::Esc` | [[rust-enum]] |
| From 트레이트 | `KeyEvent::from(KeyCode)` (테스트) | [[rust-traits]] |
| 모듈 비공개 | `mod event` (repl 내부에서만) | [[rust-modules]] |

> [!info] 향후 확장
> - `Enter` → SQL 실행
> - `Char(c)` → 입력 버퍼에 문자 추가
> - `Backspace` → 문자 삭제
> - `Up/Down` → 히스토리 탐색
> - `Ctrl+C` → 입력 취소
> - `Tab` → 자동완성
