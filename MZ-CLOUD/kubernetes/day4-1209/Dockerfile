FROM nginx:1.29.4-alpine
RUN mkdir -p /usr/share/nginx/html/assets
RUN mkdir -p /usr/share/nginx/html/css
RUN mkdir -p /usr/share/nginx/html/js
COPY index.html /usr/share/nginx/html/index.html
COPY assets /usr/share/nginx/html/assets
COPY css /usr/share/nginx/html/css
COPY js /usr/share/nginx/html/js
RUN chmod -R 755 /usr/share/nginx/html
EXPOSE 80
CMD ["nginx","-g","daemon off;"]
