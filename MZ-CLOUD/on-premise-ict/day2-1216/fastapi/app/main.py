# FastAPI 프레임워크 및 HTTP 예외 처리 임포트
from fastapi import FastAPI, HTTPException
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
# JSON 처리용 (필요시 사용)
import json
# 환경변수 읽기
import os
# MySQL 데이터베이스 연결용
import pymysql
# CORS (Cross-Origin Resource Sharing) 미들웨어
from fastapi.middleware.cors import CORSMiddleware

# ============== 환경변수 설정 ==============
MYSQL_HOST = os.getenv("MYSQL_HOST" )
MYSQL_USER = os.getenv("MYSQL_USER" )
MYSQL_PASSWORD = os.getenv("MYSQL_PASSWORD")
MYSQL_DB = os.getenv("MYSQL_DB")

# FastAPI 애플리케이션 인스턴스 생성
app = FastAPI(
    title="FastAPI MySQL App",
    description="FastAPI와 MySQL 연동 예제",
    version="1.0.0"
)

# CORS 허용 도메인 설정 (* = 모든 도메인 허용)
origins = [
    "*"
]

# CORS 미들웨어 추가
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,          # 허용할 도메인
    allow_credentials=True,         # 쿠키 허용
    allow_methods=["*"],            # 모든 HTTP 메서드 허용 (GET, POST 등)
    allow_headers=["*"],            # 모든 헤더 허용
)

# ============== Root ==============
@app.get("/")
async def root():
    return {"message": "Hello World"}

# ============== Member API ==============
@app.get("/member")
def load_user():
    conn = None
    try:
        conn = pymysql.connect(
            host=MYSQL_HOST,
            user=MYSQL_USER,
            password=MYSQL_PASSWORD,
            db=MYSQL_DB,
            charset="utf8mb4",
            cursorclass=pymysql.cursors.DictCursor
        )
        return {"message": "success"}
    except Exception as e:
        return {"message": "fail", "error": str(e)}
    finally:
        if conn:
            conn.close()

# ============== 로컬 실행용 ==============
if __name__ == "__main__":
    import uvicorn
    # 개발 서버 실행 (포트 8000)
    uvicorn.run(app, host="0.0.0.0", port=8000)