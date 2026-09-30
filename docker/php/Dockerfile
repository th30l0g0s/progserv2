FROM php:8.5-apache

# msmtp : permet à mail() d'envoyer vers Mailpit
RUN apt-get update \
 && apt-get install -y --no-install-recommends msmtp unzip git \
 && docker-php-ext-install pdo_mysql mysqli \
 && a2enmod rewrite \
 && rm -rf /var/lib/apt/lists/*

# Composer (pour PHPMailer ou autres librairies)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY php.ini /usr/local/etc/php/conf.d/custom.ini

WORKDIR /var/www/html
