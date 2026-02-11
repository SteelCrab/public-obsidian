# GitHub Actions 러너

#github #actions #runner

---

워크플로우가 실행되는 환경.

## GitHub 호스팅 러너

```yaml
runs-on: ubuntu-latest
runs-on: ubuntu-22.04
runs-on: windows-latest
runs-on: macos-latest
```

| 러너 | 설명 |
|------|------|
| `ubuntu-latest` | Ubuntu 최신 |
| `ubuntu-22.04` | Ubuntu 22.04 |
| `windows-latest` | Windows Server 최신 |
| `macos-latest` | macOS 최신 |
| `macos-14` | macOS 14 (ARM) |

## 셀프 호스팅 러너

```yaml
runs-on: self-hosted
runs-on: [self-hosted, linux, x64]
```

## 컨테이너에서 실행

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: node:20
      env:
        NODE_ENV: development
      volumes:
        - my_docker_volume:/volume_mount
```
