FROM php:8.1-apache

ENV COMPOSER_ALLOW_SUPERUSER=1
RUN apt-get update -y \
    && apt-get install --no-install-recommends -y libzip-dev libsodium-dev libicu-dev \
    && apt-get install -y zlib1g-dev libxml2-dev \
    && apt-get install -y git build-essential autoconf file pkg-config re2c python3 \
    && rm -rf /var/lib/apt/lists/*

RUN pecl install xdebug && docker-php-ext-enable xdebug
RUN docker-php-ext-install zip
RUN docker-php-ext-configure intl && docker-php-ext-install intl 
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
RUN docker-php-ext-configure sodium && docker-php-ext-install sodium
RUN docker-php-ext-install soap
RUN docker-php-ext-install pdo pdo_mysql
RUN docker-php-ext-enable intl

RUN a2enmod rewrite

COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY app /var/www/html

RUN cd /var/www/html/
RUN composer update --ignore-platform-reqs
RUN composer install --ignore-platform-reqs


RUN chown -R www-data:www-data /var/www/html/*

RUN cd /var/www/html \
    && chmod -R u+w /var/www/html/data/cache/ \
    && chmod -R u+w /var/www/html/data/log/ \
    && chmod -R u+w /var/www/html/data/session/ \
    && chmod -R u+w public/docs-client/upload/ \
    && chmod -R u+w public/imgs-client/upload/

ENV APACHE_DOCUMENT_ROOT /var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf




