FROM php:7.4.0-fpm-alpine3.10 AS development

RUN apk add --update --no-cache make

RUN mkdir -p /var/cache/symfony &&  \
    mkdir -p /var/log/symfony && \
    chown www-data:www-data /var/cache/symfony && \
    chown www-data:www-data /var/log/symfony

COPY ./Makefile /tmp/Makefile

RUN make -f /tmp/Makefile install

# ---

FROM development AS debug

RUN apk add --update --no-cache --virtual .builddeps gcc libc-dev autoconf && \
    pecl install xdebug && \
    docker-php-ext-enable xdebug && \
    apk del .builddeps

COPY php.ini /usr/local/etc/php/conf.d/xdebug.ini
