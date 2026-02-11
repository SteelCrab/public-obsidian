# MongoDB 8.2 설치 가이드 (Ubuntu)

## 📦 설치

### 1. GPG 키 다운로드
```bash
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
  sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor
```

### 2. 리포지토리 추가
```bash
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.2 multiverse" | \
  sudo tee /etc/apt/sources.list.d/mongodb-org-8.2.list
```

### 3. 설치 실행
```bash
sudo apt update
sudo apt install -y mongodb-org
```

---

## 🚀 실행

### MongoDB 서비스 시작
```bash
sudo systemctl start mongod
```

### 부팅 시 자동 시작 설정
```bash
sudo systemctl enable mongod
```

### 상태 확인
```bash
sudo systemctl status mongod
```

### 서비스 중지
```bash
sudo systemctl stop mongod
```

---

## 💻 사용법

### MongoDB Shell 접속
```bash
mongosh
```

### 기본 명령어

**데이터베이스 목록 보기**
```javascript
show dbs
```

**데이터베이스 선택/생성**
```javascript
use myDatabase
```

**컬렉션 생성 및 데이터 삽입**
```javascript
db.users.insertOne({
  name: "홍길동",
  age: 30,
  email: "hong@example.com"
})
```

**데이터 조회**
```javascript
db.users.find()
```

**특정 조건 조회**
```javascript
db.users.find({ age: { $gte: 25 } })
```

**데이터 수정**
```javascript
db.users.updateOne(
  { name: "홍길동" },
  { $set: { age: 31 } }
)
```

**데이터 삭제**
```javascript
db.users.deleteOne({ name: "홍길동" })
```

**Shell 종료**
```javascript
exit
```

---

## 📌 주요 정보

- **기본 포트:** 27017
- **데이터 저장 경로:** `/var/lib/mongodb`
- **로그 파일:** `/var/log/mongodb/mongod.log`
- **설정 파일:** `/etc/mongod.conf`

---

## 🔧 문제 해결

### 소켓 파일 권한 오류 (가장 흔한 문제)
**오류 메시지:** `Failed to unlink socket file ... Operation not permitted`
```bash
# 소켓 파일 삭제
sudo rm -f /tmp/mongodb-27017.sock

# MongoDB 재시작
sudo systemctl restart mongod

# 상태 확인
sudo systemctl status mongod
```

### 서비스가 시작되지 않을 때
```bash
# 로그 확인
sudo tail -30 /var/log/mongodb/mongod.log

# 데이터 디렉토리 권한 확인
sudo chown -R mongodb:mongodb /var/lib/mongodb
```

### 포트 사용 중 확인
```bash
sudo netstat -tulpn | grep 27017
```

### mongosh 연결 실패 시
**오류:** `MongoNetworkError: connect ECONNREFUSED 127.0.0.1:27017`

1. MongoDB 서비스가 실행 중인지 확인
```bash
sudo systemctl status mongod
```

2. 실행되지 않았다면 시작
```bash
sudo systemctl start mongod
```