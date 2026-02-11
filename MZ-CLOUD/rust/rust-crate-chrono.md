# chrono - 날짜와 시간

#rust #chrono #날짜 #시간 #크레이트

---

날짜, 시간, 타임존을 다루는 라이브러리.

## 설치

```toml
[dependencies]
chrono = "0.4"
```

## 현재 시간

```rust
use chrono::{Utc, Local};

let now_utc = Utc::now();        // UTC 시간
let now_local = Local::now();    // 로컬 시간

println!("UTC: {}", now_utc);
println!("로컬: {}", now_local);
```

## 날짜/시간 생성

```rust
use chrono::{NaiveDate, NaiveDateTime, NaiveTime};

// 날짜
let date = NaiveDate::from_ymd_opt(2024, 1, 15).unwrap();

// 시간
let time = NaiveTime::from_hms_opt(14, 30, 0).unwrap();

// 날짜 + 시간
let dt = NaiveDateTime::new(date, time);
let dt = date.and_hms_opt(14, 30, 0).unwrap();
```

## 포매팅과 파싱

```rust
use chrono::NaiveDate;

// 포매팅
let date = Utc::now();
println!("{}", date.format("%Y-%m-%d %H:%M:%S"));  // 2024-01-15 14:30:00
println!("{}", date.format("%Y년 %m월 %d일"));       // 2024년 01월 15일

// 파싱
let dt = NaiveDate::parse_from_str("2024-01-15", "%Y-%m-%d").unwrap();
```

## 주요 포맷 지정자

| 지정자 | 설명 | 예시 |
|--------|------|------|
| `%Y` | 4자리 연도 | 2024 |
| `%m` | 월 (01-12) | 01 |
| `%d` | 일 (01-31) | 15 |
| `%H` | 시 (00-23) | 14 |
| `%M` | 분 (00-59) | 30 |
| `%S` | 초 (00-59) | 00 |
| `%A` | 요일 | Monday |

## 날짜 연산

```rust
use chrono::Duration;

let now = Utc::now();
let tomorrow = now + Duration::days(1);
let last_week = now - Duration::weeks(1);

let diff = tomorrow - now;
println!("차이: {}시간", diff.num_hours());
```

> [!info] Naive vs 타임존
> `Naive*` 타입은 타임존 정보가 없다.
> `DateTime<Utc>`, `DateTime<Local>`은 타임존을 포함한다.
