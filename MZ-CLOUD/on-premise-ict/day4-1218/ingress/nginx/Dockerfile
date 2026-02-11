FROM nginx:1.29.4-alpine
EXPOSE 80

COPY index.html /usr/share/nginx/html/

COPY default.conf /etc/nginx/conf.d/
CMD ["nginx", "-g", "daemon off;"]
