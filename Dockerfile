FROM alpine:latest
MAINTAINER Jeroen Geusebroek <me@jeroengeusebroek.nl>

ARG VERSION=1.4.0

ENV GID=991 UID=991

RUN apk -U add \
    curl \
    nginx \
    php7-fpm \
    php7-gd \
    php7-json \
    php7-pdo \
    php7-pdo_mysql \
    php7-pdo_pgsql \
    supervisor \
    ca-certificates \
    tar \
    gnupg \
 && mkdir -p privatebin/data \
 && export GNUPGHOME="$(mktemp -d)" \
 && gpg2 --list-public-keys || /bin/true \
 && curl -s https://privatebin.info/key/release.asc | gpg2 --import - \
 && curl -Lso privatebin.tar.gz.asc https://github.com/PrivateBin/PrivateBin/releases/download/$VERSION/PrivateBin-$VERSION.tar.gz.asc \
 && curl -Lso privatebin.tar.gz https://github.com/PrivateBin/PrivateBin/archive/$VERSION.tar.gz \
 && gpg2 --verify privatebin.tar.gz.asc \
 && rm -rf "$GNUPGHOME" /var/www/* \
 && cd /var/www \
 && tar -xzf /privatebin.tar.gz --strip 1 \
 && mv cfg/conf.sample.php /privatebin/ \
 && mv cfg /privatebin/ \
 && mv lib /privatebin \
 && mv tpl /privatebin \
 && mv vendor /privatebin \
 && sed -i "s#define('PATH', '');#define('PATH', '/privatebin/');#" index.php \
 && apk del tar ca-certificates curl gnupg \
 && rm -f /privatebin.tar.gz* *.md /var/cache/apk/*

COPY files/nginx.conf /etc/nginx/nginx.conf
COPY files/php-fpm.conf /etc/php7/php-fpm.conf
COPY files/supervisord.conf /usr/local/etc/supervisord.conf
COPY entrypoint.sh /

# Mark dirs as volumes that need to be writable, allows running the container --read-only
VOLUME [ "/privatebin/data", "/privatebin/cfg", "/etc", "/tmp", "/var/lib/nginx/tmp", "/run", "/var/log" ]

EXPOSE 80
LABEL description "PrivateBin is a minimalist, open source online pastebin where the server has zero knowledge of pasted data."
CMD ["/entrypoint.sh"]
