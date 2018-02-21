#!/bin/sh

addgroup -g ${GID} privatebin && adduser -h /privatebin -s /bin/sh -D -G privatebin -u ${UID} privatebin
touch /var/run/php-fpm.sock

if [ ! -f /privatebin/cfg/conf.php ]; then
	cp /privatebin/conf.sample.php /privatebin/cfg/conf.php
fi

chown -R privatebin:privatebin /privatebin /var/run/php-fpm.sock /var/lib/nginx /tmp /var/tmp/nginx
supervisord -c /usr/local/etc/supervisord.conf
