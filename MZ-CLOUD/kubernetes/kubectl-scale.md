# Kubectl 스케일링

#kubernetes #kubectl #scale

---

레플리카 수 조정.

| 명령어 | 설명 |
|--------|------|
| `kubectl scale deploy <이름> --replicas=3` | 레플리카 조정 |
| `kubectl scale rs <이름> --replicas=3` | ReplicaSet 조정 |
| `kubectl scale sts <이름> --replicas=3` | StatefulSet 조정 |
| `kubectl autoscale deploy <이름> --min=2 --max=10 --cpu-percent=80` | HPA 설정 |
