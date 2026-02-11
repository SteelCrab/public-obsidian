# Kubectl 파일 복사

#kubernetes #kubectl #cp

---

컨테이너와 파일 복사.

| 명령어 | 설명 |
|--------|------|
| `kubectl cp <pod>:<경로> <로컬경로>` | 컨테이너에서 로컬로 |
| `kubectl cp <로컬경로> <pod>:<경로>` | 로컬에서 컨테이너로 |
| `kubectl cp <pod>:<경로> <로컬경로> -c <컨테이너>` | 특정 컨테이너 |
