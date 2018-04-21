FROM composer as composer

COPY . /app

RUN composer install --no-scripts --prefer-dist --ignore-platform-reqs

RUN cp .env.example .env && php ./vendor/bin/phpunit

RUN composer install --no-scripts --prefer-dist --no-dev --ignore-platform-reqs

FROM nasajon/php:7.1-fpm

USER nginx

COPY --from=composer /app/ /var/www/html

USER root

RUN sed -i "s#root /var/www/html;#root /var/www/html/public;#" /etc/nginx/conf.d/default.conf && \
    echo 'security.limit_extensions = ' >> /etc/php7/php-fpm.conf && \
    sed -i 's/cgi.fix_pathinfo=0/cgi.fix_pathinfo=1/g' /etc/php7/php.ini
    
RUN chmod -fR 777 storage && chmod -fR 777 bootstrap/cache
