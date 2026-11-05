# Versión fijada para que Dependabot proponga cada parche. 8.4.27 incluye los parches de php2shell (CVE-2026-109618 y CVE-2026-109619).
FROM serversideup/php:8.5.0-fpm-nginx

USER root
RUN install-php-extensions gd intl exif
COPY --chmod=644 docker/php.ini /usr/local/etc/php/conf.d/zz-flarum.ini
COPY --chmod=644 docker/nginx-flarum.conf /etc/nginx/server-opts.d/flarum.conf
COPY --chmod=755 docker/entrypoint.d/ /etc/entrypoint.d/
RUN docker-php-serversideup-s6-init
USER www-data

ENV PHP_MEMORY_LIMIT=256M \
    PHP_UPLOAD_MAX_FILE_SIZE=20M \
    PHP_POST_MAX_SIZE=20M \
    NGINX_CLIENT_MAX_BODY_SIZE=20M \
    PHP_OPCACHE_ENABLE=1 \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS=0 \
    TRUSTED_PROXY=cloudflare

COPY --chown=www-data:www-data composer.json composer.lock ./
COPY --chown=www-data:www-data extensions/ extensions/
RUN composer install --no-dev --no-interaction --no-progress --optimize-autoloader

COPY --chown=www-data:www-data . .
