### 플레이스 홀더
|변수|값|

```dockerfile
# FastAPI 이미지
# 포트: 3000

FROM python:3.14-alpine

WORKDIR /app

# 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 애플리케이션 복사
COPY main.py .

# 포트 노출
EXPOSE 3000

# uvicorn으로 실행
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

```