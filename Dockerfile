FROM rogercastaneda/nginx-alpine37:0.1

LABEL version="0.1"
LABEL description="Basic nginx image with ssl for local development projects with php7.1"
LABEL maintainer="roger.castaneda@bonzzu.com"

ENV COMPOSER_PATH /usr/local/bin
ENV COMPOSER_EXIT_ON_PATCH_FAILURE 1
ENV PHP_FPM_ERROR_LOG /proc/self/fd/2
ENV PHP_PID_DIR /var/run/php

COPY ./conf /conf
COPY ./scripts /scripts

RUN apk --no-cache add php7 php7-fpm php7-json php7-zlib php7-xml php7-phar php7-iconv php7-mcrypt curl php7-curl php7-openssl php7-gd && \
  mkdir -p ${PHP_PID_DIR}/ && \
  chown ${NGINX_RUN_USER}:${NGINX_RUN_GROUP} ${PHP_PID_DIR}/ && \
  curl -sS https://getcomposer.org/installer | php -- --install-dir=${COMPOSER_PATH} --filename=composer && \
  cp /conf/nginx/app.conf /etc/nginx/conf.d/app.conf && \
  cp /conf/php/app-php.ini /etc/php7/conf.d/zz_app.ini && \
  cp /conf/php/app-php-fpm.conf /etc/php7/php-fpm.d/zz_app.conf && \
  chmod -R 755 /scripts

RUN \
  apk add --no-cache php7-pdo_mysql php7-zip php7-simplexml php7-xmlreader php7-mbstring php7-apcu php7-xmlrpc php7-memcached php7-dom php7-tokenizer php7-xmlwriter

RUN \
  apk add --update openssh openssl && \
  mkdir -p /etc/nginx/ssl && \
  openssl genrsa -out /etc/nginx/ssl/dummy.key 2048 && \
  openssl req -new -key /etc/nginx/ssl/dummy.key -out /etc/nginx/ssl/dummy.csr -subj "/C=GB/L=London/O=Company Ltd/CN=docker" && \
  openssl x509 -req -days 3650 -in /etc/nginx/ssl/dummy.csr -signkey /etc/nginx/ssl/dummy.key -out /etc/nginx/ssl/dummy.crt

WORKDIR /app

EXPOSE 80 443