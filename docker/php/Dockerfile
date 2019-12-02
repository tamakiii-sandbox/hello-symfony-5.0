FROM php:7.4.0-fpm-alpine3.10

RUN apk add --update --no-cache make

COPY ./Makefile /tmp/Makefile

RUN make -f /tmp/Makefile install
