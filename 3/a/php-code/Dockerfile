FROM php:7.4-apache

RUN apt update \
    && apt install -y vim\
    && docker-php-ext-install mysqli \
    && docker-php-ext-enable mysqli

COPY . /var/www/html

