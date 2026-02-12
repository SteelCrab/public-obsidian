FROM nginx:alpine

COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

WORKDIR /usr/share/nginx/html

RUN rm -rf ./*

COPY --chown=nginx:nginx html/ .
COPY --chown=nginx:nginx images/ ./images/

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

EXPOSE 80


CMD ["nginx", "-g", "daemon off;"]



