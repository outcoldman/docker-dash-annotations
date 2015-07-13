FROM php:apache
MAINTAINER Denis Gladkikh <docker-dash-annotations@denis.gladkikh.email>

ENV DASH_ANNOTATIONS_VERSION 1.0.0

ENV PHP_REDIS_VERSION 2.2.7

RUN apt-get update \
    && apt-get install -y --no-install-recommends git-core libzip-dev python python-pip \
    && docker-php-ext-install mbstring zip pdo_mysql \
    && php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require "laravel/lumen-installer=~1.0" \
    && (curl -L https://github.com/phpredis/phpredis/archive/${PHP_REDIS_VERSION}.tar.gz | tar xz -C /tmp/ \
        && cd /tmp/phpredis-${PHP_REDIS_VERSION} \
        && phpize \
        && ./configure \
        && make -j"$(nproc)" \
        && make install \
        && rm -fR /tmp/phpredis-${PHP_REDIS_VERSION} \
        && echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini) \
    && cd /var/www/ \
    && rm -fR /var/www/html \
    && /root/.composer/vendor/bin/lumen new html \
    && cd /var/www/html \
    && curl -L https://github.com/Kapeli/Dash-Annotations/archive/v${DASH_ANNOTATIONS_VERSION}.tar.gz | tar xz -C . --strip=1 \
    && pip install -r requirements.txt \
    && ln -s /usr/local/bin/pygmentize /bin/pygmentize \
    && apt-get purge -y libzip-dev python-pip \
    && a2enmod rewrite
    && (chown -R www-data:www-data . && chmod -R 777 storage && chmod -R 777 public)

COPY entrypoint.sh /sbin/
RUN chmod +x /sbin/entrypoint.sh

CMD ["/sbin/entrypoint.sh"]
