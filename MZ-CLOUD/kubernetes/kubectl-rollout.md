# Kubectl 롤아웃 관리

#kubernetes #kubectl #rollout

---

디플로이먼트 롤아웃 관리.

| 명령어 | 설명 |
|--------|------|
| `kubectl rollout status deploy/<이름>` | 롤아웃 상태 |
| `kubectl rollout history deploy/<이름>` | 롤아웃 히스토리 |
| `kubectl rollout undo deploy/<이름>` | 이전 버전으로 롤백 |
| `kubectl rollout undo deploy/<이름> --to-revision=2` | 특정 버전으로 롤백 |
| `kubectl rollout restart deploy/<이름>` | 롤링 재시작 |
| `kubectl rollout pause deploy/<이름>` | 롤아웃 일시정지 |
| `kubectl rollout resume deploy/<이름>` | 롤아웃 재개 |
