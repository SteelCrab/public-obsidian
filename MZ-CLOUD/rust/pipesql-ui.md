# PipeSQL 터미널 UI 렌더링

#pipesql #rust #repl #ui #ratatui

---

ratatui 프레임워크로 터미널 UI를 렌더링한다.

> 소스: `src/repl/ui.rs`

## 렌더 함수

```rust
use ratatui::{
    Frame,
    widgets::{Block, Borders},
};

pub fn render(frame: &mut Frame) {
    let block = Block::default()
        .title(" PipeSQL ")
        .borders(Borders::ALL);
    frame.render_widget(block, frame.area());
}
```

## 현재 화면

```
┌─ PipeSQL ────────────────────────────────┐
│                                          │
│                                          │
│                                          │
│                                          │
└──────────────────────────────────────────┘
```

전체 터미널 영역에 `" PipeSQL "` 타이틀과 사방 테두리를 그린다.

## ratatui 핵심 개념

| 개념 | 설명 |
|------|------|
| `Frame` | 한 프레임의 렌더링 컨텍스트 |
| `frame.area()` | 터미널 전체 영역 (`Rect`) |
| `Block` | 테두리 + 타이틀 위젯 |
| `Borders::ALL` | 상하좌우 전체 테두리 |
| `render_widget()` | 위젯을 영역에 그리기 |

## 호출 흐름

```
App::run_loop()
    ↓
terminal.draw(ui::render)?      콜백으로 render 전달
    ↓
render(frame)
    ├── Block::default()         빈 블록 생성
    │   .title(" PipeSQL ")      타이틀 설정
    │   .borders(Borders::ALL)   테두리 설정
    └── frame.render_widget()    화면에 그리기
```

`terminal.draw()`는 함수 포인터(`fn(&mut Frame)`)를 콜백으로 받는다.

## ratatui 주요 위젯

| 위젯 | 용도 | 향후 활용 |
|------|------|----------|
| `Block` | 테두리/타이틀 컨테이너 | 현재 사용 |
| `Paragraph` | 텍스트 표시 | SQL 입력/출력 |
| `Table` | 표 형식 데이터 | SELECT 결과 |
| `List` | 목록 표시 | 히스토리 |
| `Tabs` | 탭 전환 | 모드 전환 |

## 사용된 Rust 패턴

| 패턴 | 설명 | 관련 노트 |
|------|------|----------|
| 함수를 인자로 전달 | `terminal.draw(ui::render)` | [[rust-closures]] |
| 빌더 패턴 | `Block::default().title().borders()` | [[rust-struct]] |
| 가변 참조 | `frame: &mut Frame` | [[rust-borrowing]] |

## 향후 레이아웃 계획

```
┌─ PipeSQL ────────────────────────────────┐
│ pipesql> SELECT * FROM users;            │ ← 입력 영역
│──────────────────────────────────────────│
│ id │ name   │ age                        │ ← 결과 영역
│  1 │ 김철수 │  30                        │   (Table 위젯)
│  2 │ 이영희 │  25                        │
│──────────────────────────────────────────│
│ 3 rows returned (0.02ms)                 │ ← 상태 바
└──────────────────────────────────────────┘
```

ratatui의 `Layout`으로 영역을 분할하여 구현한다.

```rust
// 향후 구현 예시
use ratatui::layout::{Layout, Direction, Constraint};

let chunks = Layout::default()
    .direction(Direction::Vertical)
    .constraints([
        Constraint::Length(3),       // 입력 영역
        Constraint::Min(5),          // 결과 영역
        Constraint::Length(1),       // 상태 바
    ])
    .split(frame.area());
```

> [!info] Immediate Mode 렌더링
> ratatui는 매 프레임마다 전체 화면을 다시 그리는 즉시 모드(immediate mode) 방식이다.
> 상태 변경 시 별도의 업데이트 호출 없이 다음 `draw()` 호출에서 반영된다.
