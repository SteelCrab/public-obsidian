# WordPress 최신 Alpine 이미지
FROM wordpress:php8.3-fpm-alpine

# 취약점 패치 - libpng 업데이트
RUN apk update && apk upgrade libpng --no-cache

# Timezone 설정 (한국 시간)
ENV TZ=Asia/Seoul

# WordPress 포트 노출
EXPOSE 9000
