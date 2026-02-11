# Rust Vec (벡터)

#rust #벡터 #vec #컬렉션

---

가변 길이 배열. 힙에 저장되며 동적으로 크기가 변한다.

## 생성

```rust
let v: Vec<i32> = Vec::new();     // 빈 벡터
let v = vec![1, 2, 3];            // 매크로로 생성
let v = vec![0; 5];               // [0, 0, 0, 0, 0]
```

## 요소 추가/제거

| 메서드 | 설명 |
|--------|------|
| `v.push(값)` | 끝에 추가 |
| `v.pop()` | 끝에서 제거 (Option 반환) |
| `v.insert(인덱스, 값)` | 특정 위치에 삽입 |
| `v.remove(인덱스)` | 특정 위치 제거 |
| `v.retain(\|x\| 조건)` | 조건에 맞는 요소만 유지 |
| `v.clear()` | 모든 요소 제거 |

## 요소 접근

```rust
let v = vec![1, 2, 3, 4, 5];

let third = &v[2];              // 인덱스 접근 (범위 초과 시 panic)
let third = v.get(2);           // Option<&T> 반환 (안전)

match v.get(10) {
    Some(val) => println!("{}", val),
    None => println!("범위 초과"),
}
```

## 반복

```rust
let v = vec![1, 2, 3];

// 불변 반복
for val in &v {
    println!("{}", val);
}

// 가변 반복
let mut v = vec![1, 2, 3];
for val in &mut v {
    *val *= 2;
}

// 소유권 이동 반복
for val in v {
    println!("{}", val);   // v는 이후 사용 불가
}
```

## 유용한 메서드

| 메서드 | 설명 |
|--------|------|
| `v.len()` | 길이 |
| `v.is_empty()` | 비어있는지 확인 |
| `v.contains(&값)` | 포함 여부 |
| `v.sort()` | 정렬 |
| `v.dedup()` | 연속 중복 제거 |
| `v.iter()` | 반복자 생성 |
| `v.extend(다른_vec)` | 다른 벡터 이어 붙이기 |

> [!info] Vec과 반복자
> `v.iter()`, `v.iter_mut()`, `v.into_iter()`로 반복자를 생성한다.
> 자세한 내용은 [[rust-iterators]] 참조.
