# Alpine Image for Nginx and PHP

# NGINX x ALPINE.
FROM nginx:1.15.7-alpine

# AUTHORS OF THE PACKAGE.
LABEL authors="Neo Ighodaro <neo@creativitykills.co>, Oshane Bailey <b4.oshany@gmail.com>"

# INSTALL SOME SYSTEM PACKAGES.
RUN apk --update --no-cache add ca-certificates \
    bash \
    supervisor

# IMAGE ARGUMENTS WITH DEFAULTS.
ARG PHP_VERSION=7.2
ARG ALPINE_VERSION=3.7
ARG COMPOSER_HASH=a5c698ffe4b8e849a443b120cd5ba38043260d5c4023dbf93e1558871f1f07f58274fc6f4c93bcfd858c6bd0775cd8d1
ARG NGINX_HTTP_PORT=80
ARG NGINX_HTTPS_PORT=443

# CONFIGURE ALPINE REPOSITORIES AND PHP BUILD DIR.
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v${ALPINE_VERSION}/community" >> /etc/apk/repositories

# INSTALL PHP AND SOME EXTENSIONS. SEE: https://github.com/codecasts/php-alpine
RUN apk add --no-cache --update \
    gd \
    freetype \
    libpng \
    mysql-client \
    libjpeg-turbo \
    freetype-dev \
    libpng-dev \
    nodejs \
    git \
    php7 \
    php7-fpm \
    php7-openssl \
    php7-pdo \
    php7-pdo_mysql \
    php7-mbstring \
    php7-phar \
    php7-session \
    php7-mcrypt \
    php7-dom \
    php7-curl \
    php7-ctype \
    php7-zlib \
    php7-json \
    php7-dom \
    php7-gd \
    php7-zip \
    php7-xml \
    php7-tokenizer \
    php7-iconv \
    php7-simplexml \
    php7-fileinfo \
    php7-calendar \
    php7-exif \
    php7-ftp \
    php7-gettext \
    php7-pcntl \
    php7-posix \
    php7-shmop \
    php7-wddx \
    php7-xmlreader \
    php7-xmlwriter \
    php7-xsl
    # ln -s /usr/bin/php7 /usr/bin/php

# INSTALL CURL
RUN apk --no-cache add curl

# CONFIGURE WEB SERVER.
RUN mkdir -p /var/www && \
    mkdir -p /run/php && \
    mkdir -p /run/nginx && \
    mkdir -p /var/log/supervisor && \
    mkdir -p /etc/nginx/sites-enabled && \
    mkdir -p /etc/nginx/sites-available && \
    rm /etc/nginx/nginx.conf && \
    rm /etc/php7/php-fpm.d/www.conf && \
    rm /etc/php7/php.ini

# INSTALL COMPOSER.
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '${COMPOSER_HASH}') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/bin --filename=composer && \
    php -r "unlink('composer-setup.php');"

# ADD START SCRIPT, SUPERVISOR CONFIG, NGINX CONFIG AND RUN SCRIPTS.
ADD start.sh /start.sh
ADD config/supervisor/supervisord.conf /etc/supervisord.conf
ADD config/nginx/nginx.conf /etc/nginx/nginx.conf
ADD config/nginx/site.conf /etc/nginx/sites-available/default.conf
ADD config/php/php.ini /etc/php7/php.ini
ADD config/php-fpm/www.conf /etc/php7/php-fpm.d/www.conf
RUN chmod 755 /start.sh

# EXPOSE PORTS!
EXPOSE ${NGINX_HTTPS_PORT} ${NGINX_HTTP_PORT}

# SET THE WORK DIRECTORY.
WORKDIR /var/www

# KICKSTART!
CMD ["/start.sh"]
