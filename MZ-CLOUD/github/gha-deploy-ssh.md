# GitHub Actions SSH 배포

#github #actions #ssh #deploy #ec2

---

SSH로 원격 서버 배포.

## appleboy/ssh-action

```yaml
- uses: appleboy/ssh-action@v1.0.3
  with:
    host: ${{ secrets.HOST }}
    username: ${{ secrets.USERNAME }}
    key: ${{ secrets.SSH_KEY }}
    script: |
      echo "Hello"
```

## EC2 배포 예시

```yaml
- uses: appleboy/ssh-action@v1.0.3
  with:
    host: ${{ secrets.EC2_HOST }}
    username: ${{ secrets.EC2_USERNAME }}
    key: ${{ secrets.SSH_KEY }}
    script: |
      docker pull ${{ secrets.DOCKER_USERNAME }}/app:latest
      docker stop app || true
      docker rm app || true
      docker run -d --name app -p 8000:8000 ${{ secrets.DOCKER_USERNAME }}/app:latest
```

## 옵션

| 옵션 | 설명 |
|------|------|
| `host` | 서버 호스트 |
| `username` | SSH 사용자 |
| `key` | SSH 개인키 |
| `password` | 비밀번호 (key 대신) |
| `port` | SSH 포트 (기본 22) |
| `script` | 실행할 스크립트 |
| `timeout` | 타임아웃 |
| `script_stop` | 에러 시 중단 |

## 필요한 시크릿

| 시크릿 | 설명 |
|--------|------|
| `EC2_HOST` | 서버 IP 또는 도메인 |
| `EC2_USERNAME` | ec2-user, ubuntu 등 |
| `SSH_KEY` | ~/.ssh/id_rsa 개인키 전체 |

## 여러 서버 배포

```yaml
- uses: appleboy/ssh-action@v1.0.3
  with:
    host: "server1.com,server2.com"
    username: deploy
    key: ${{ secrets.SSH_KEY }}
    script: ./deploy.sh
```

## 파일 전송 (scp)

```yaml
- uses: appleboy/scp-action@v0.1.7
  with:
    host: ${{ secrets.HOST }}
    username: ${{ secrets.USERNAME }}
    key: ${{ secrets.SSH_KEY }}
    source: "dist/*"
    target: "/var/www/app"
```
