# Python 3.12 Alpine 이미지 (경량화 + 보안)
FROM python:3.12-alpine

# 작업 디렉토리를 /app으로 설정
WORKDIR /app

# 빌드 도구 설치 (일부 패키지 컴파일에 필요)
RUN apk add --no-cache gcc musl-dev

# 현재 디렉토리의 requirements.txt 파일을 컨테이너의 /app/requirements.txt로 복사
COPY ./requirements.txt /app/requirements.txt

# requirements.txt에 명시된 의존성 패키지들을 설치 (캐시 사용 안 함)
RUN pip install --no-cache-dir -r requirements.txt

# 현재 디렉토리의 app 폴더 내용을 컨테이너의 /app으로 복사
COPY ./app /app

# 컨테이너 시작 시 uvicorn을 사용하여 FastAPI 애플리케이션 실행
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
