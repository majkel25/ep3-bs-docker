FROM php:8.1-apache

# Allow composer as root
ENV COMPOSER_ALLOW_SUPERUSER=1

# Install system dependencies
RUN apt-get update -y \
    && apt-get install --no-install-recommends -y \
        libzip-dev \
        libsodium-dev \
        libicu-dev \
        zlib1g-dev \
        libxml2-dev \
        git \
        unzip \
        curl \
        build-essential \
        autoconf \
        file \
        pkg-config \
        re2c \
        python3 \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN pecl install xdebug && docker-php-ext-enable xdebug
RUN docker-php-ext-install zip
RUN docker-php-ext-configure intl && docker-php-ext-install intl
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
RUN docker-php-ext-configure sodium && docker-php-ext-install sodium
RUN docker-php-ext-install soap
RUN docker-php-ext-install pdo pdo_mysql

# -------------------------------------------------------------
# Install Composer
# -------------------------------------------------------------
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && rm composer-setup.php

# -------------------------------------------------------------
# Copy main application from Git submodule
# -------------------------------------------------------------
COPY app /var/www/html

WORKDIR /var/www/html

# Run composer inside container
RUN composer install --no-dev --ignore-platform-reqs --optimize-autoloader

# -------------------------------------------------------------
# Overlay docker-specific files (init.php, .htaccess, etc.)
# -------------------------------------------------------------
COPY install/app /var/www/html

# -------------------------------------------------------------
# Fix permissions
# -------------------------------------------------------------
RUN chown -R www-data:www-data /var/www/html/* \
    && chmod -R u+w /var/www/html/data/cache/ \
    && chmod -R u+w /var/www/html/data/log/ \
    && chmod -R u+w /var/www/html/data/session/ \
    && chmod -R u+w public/docs-client/upload/ \
    && chmod -R u+w public/imgs-cli
