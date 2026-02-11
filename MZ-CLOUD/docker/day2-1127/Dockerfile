FROM nginx:mainline-alpine

# 기본 설정 파일 덮어쓰기 (필요한 경우)
COPY nginx.conf /etc/nginx/nginx.conf

# 작업 디렉토리 설정
WORKDIR /usr/share/nginx/html

# (선택사항) 기본 index.html 제거
RUN rm -rf ./*

# 포트 노출
EXPOSE 80

# Nginx 실행
CMD ["nginx", "-g", "daemon off;"]
