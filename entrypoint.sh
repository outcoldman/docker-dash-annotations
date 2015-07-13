#!/bin/bash

cp .env.example .env

# If mysql container is linked
if [[ -n ${MYSQL_PORT_3306_TCP_ADDR} ]]; then
  DB_CONNECTION=${DB_CONNECTION:-mysql}
  DB_HOST=${DB_HOST:-${MYSQL_PORT_3306_TCP_ADDR}}
  DB_DATABASE=${DB_DATABASE:-${MYSQL_ENV_MYSQL_DATABASE}}
  DB_USERNAME=${DB_USERNAME:-${MYSQL_ENV_MYSQL_USER}}
  DB_PASSWORD=${DB_PASSWORD:-${MYSQL_ENV_MYSQL_PASSWORD}}
fi

APP_KEY="${APP_KEY:-RandomKey}"

APP_ENV="${APP_ENV:-local}"
APP_DEBUG="${APP_DEBUG:-false}"
APP_LOCALE="${APP_LOCALE:-en}"
APP_FALLBACK_LOCALE="${APP_FALLBACK_LOCALE:-en}"

DB_CONNECTION="${DB_CONNECTION:-mysql}"
DB_HOST="${DB_HOST:-mysql}"
DB_DATABASE="${DB_DATABASE:-annotations}"
DB_USERNAME="${DB_USERNAME:-mysql_username}"
DB_PASSWORD="${DB_PASSWORD:-mysql_password}"

CACHE_DRIVER="${CACHE_DRIVER:-file}"
SESSION_DRIVER="${SESSION_DRIVER:-file}"
QUEUE_DRIVER="${QUEUE_DRIVER:-sync}"

sed 's/APP_KEY=SomeRandomKey!/'APP_KEY="${APP_KEY}"'/' -i .env

sed 's/APP_ENV=local/'APP_ENV="${APP_ENV}"'/' -i .env
sed 's/APP_DEBUG=true/'APP_DEBUG="${APP_DEBUG}"'/' -i .env
sed 's/APP_LOCALE=en/'APP_LOCALE="${APP_LOCALE}"'/' -i .env
sed 's/APP_FALLBACK_LOCALE=en/'APP_FALLBACK_LOCALE="${APP_FALLBACK_LOCALE}"'/' -i .env

sed 's/DB_CONNECTION=mysql/'DB_CONNECTION="${DB_CONNECTION}"'/' -i .env
sed 's/DB_HOST=localhost/'DB_HOST="${DB_HOST}"'/' -i .env
sed 's/DB_DATABASE=annotations/'DB_DATABASE="${DB_DATABASE}"'/' -i .env
sed 's/DB_USERNAME=mysql_username/'DB_USERNAME="${DB_USERNAME}"'/' -i .env
sed 's/DB_PASSWORD=mysql_password/'DB_PASSWORD="${DB_PASSWORD}"'/' -i .env

sed 's/CACHE_DRIVER=file/'CACHE_DRIVER="${CACHE_DRIVER}"'/' -i .env
sed 's/SESSION_DRIVER=file/'SESSION_DRIVER="${SESSION_DRIVER}"'/' -i .env
sed 's/QUEUE_DRIVER=sync/'QUEUE_DRIVER="${QUEUE_DRIVER}"'/' -i .env

if [[ -n ${GITHUB_TOKEN} ]];then
  composer config -g github-oauth.github.com ${GITHUB_TOKEN}
fi

composer install --no-dev --no-scripts
php artisan migrate --force

mkdir -p /var/www/storage/logs
chown -R www-data:www-data /var/www

apache2-foreground
