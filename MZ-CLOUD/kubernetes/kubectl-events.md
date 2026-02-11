# Kubectl 이벤트 조회

#kubernetes #kubectl #events #디버깅

---

클러스터 이벤트 확인.

| 명령어 | 설명 |
|--------|------|
| `kubectl get events` | 이벤트 목록 |
| `kubectl get events --sort-by=.lastTimestamp` | 시간순 정렬 |
| `kubectl get events -w` | 실시간 감시 |
| `kubectl get events --field-selector type=Warning` | 경고만 |
| `kubectl get events -n <ns>` | 특정 네임스페이스 |
