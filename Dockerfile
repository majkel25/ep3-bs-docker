FROM php:8.1-apache

# Allow composer as root
ENV COMPOSER_ALLOW_SUPERUSER=1

# -------------------------------------------------------------
# System packages
# -------------------------------------------------------------
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

# -------------------------------------------------------------
# PHP extensions
# -------------------------------------------------------------
RUN pecl install xdebug && docker-php-ext-enable xdebug
RUN docker-php-ext-install zip
RUN docker-php-ext-configure intl && docker-php-ext-install intl
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
RUN docker-php-ext-configure sodium && docker-php-ext-install sodium
RUN docker-php-ext-install soap
RUN docker-php-ext-install pdo pdo_mysql

# -------------------------------------------------------------
# Install Composer inside the image
# -------------------------------------------------------------
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && rm composer-setup.php

# -------------------------------------------------------------
# Copy ep3-bs app (submodule output)
# -------------------------------------------------------------
COPY app /var/www/html

WORKDIR /var/www/html

# Install PHP dependencies
RUN composer install --no-dev --ignore-platform-reqs --optimize-autoloader

# -------------------------------------------------------------
# Apache Configuration
# -------------------------------------------------------------
# Enable required mods
RUN a2enmod rewrite headers

# Set DocumentRoot to /public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Write full VirtualHost (correct and complete config)
RUN printf '%s\n' \
  '<VirtualHost *:80>' \
  '    ServerAdmin webmaster@localhost' \
  '    DocumentRoot /var/www/html/public' \
  '    <Directory /var/www/html/public>' \
  '        Options Indexes FollowSymLinks' \
  '        AllowOverride All' \
  '        Require all granted' \
  '    </Directory>' \
  '    ErrorLog ${APACHE_LOG_DIR}/error.log' \
  '    CustomLog ${APACHE_LOG_DIR}/access.log combined' \
  '</VirtualHost>' \
  > /etc/apache2/sites-available/000-default.conf

# -------------------------------------------------------------
# Ensure .htaccess exists (Zend requires front-controller routing)
# -------------------------------------------------------------
RUN if [ ! -s public/.htaccess ]; then \
    printf '%s\n' \
'RewriteEngine On' \
'RewriteCond %{REQUEST_FILENAME} -s [OR]' \
'RewriteCond %{REQUEST_FILENAME} -l [OR]' \
'RewriteCond %{REQUEST_FILENAME} -d' \
'RewriteRule ^.*$ - [NC,L]' \
'RewriteRule ^.*$ index.php [NC,L]' \
    > public/.htaccess; \
  fi

# -------------------------------------------------------------
# Permissions / Writable folders
# -------------------------------------------------------------
RUN mkdir -p \
      /var/www/html/public/docs-client/upload \
      /var/www/html/public/imgs-client/upload \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R u+w /var/www/html/data/cache/ \
    && chmod -R u+w /var/www/html/data/log/ \
    && chmod -R u+w /var/www/html/data/session/ \
    && chmod -R u+w /var/www/html/public/docs-client/upload/ \
    && chmod -R u+w /var/www/html/public/imgs-client/upload/

EXPOSE 80

CMD ["apache2-foreground"]
