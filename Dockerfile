# Sentrifugo 3.2 on Apache + PHP 8.1
ARG SENTRIFUGO_VERSION=3.2
FROM php:7.4-apache

# PHP extensions & deps (your script should install $PHPIZE_DEPS, libonig-dev, libicu-dev, etc.)
COPY docker/scripts/install-exts.sh /usr/local/bin/install-exts.sh
RUN chmod +x /usr/local/bin/install-exts.sh && /usr/local/bin/install-exts.sh

# PHP runtime tweaks
COPY docker/php/sentrifugo.ini /usr/local/etc/php/conf.d/sentrifugo.ini
COPY docker/php/errors.ini      /usr/local/etc/php/conf.d/errors.ini

# Apache configs (.htaccess override + ServerName)
COPY docker/apache/sentrifugo-override.conf /etc/apache2/conf-available/sentrifugo-override.conf
COPY docker/apache/servername.conf          /etc/apache2/conf-available/servername.conf
RUN a2enconf sentrifugo-override servername

# Download and stage Sentrifugo source
COPY docker/scripts/fetch-sentrifugo.sh /usr/local/bin/fetch-sentrifugo.sh
RUN chmod +x /usr/local/bin/fetch-sentrifugo.sh \
&& /usr/local/bin/fetch-sentrifugo.sh "${SENTRIFUGO_VERSION}"

# Import Sentrifugo
# COPY . /usr/src/sentrifugo

# PHP 8 fix: overwrite legacy PHPMailer autoloader
# COPY docker/patches/PHPMailerAutoload.php /usr/src/sentrifugo/install/PHPMailer/PHPMailerAutoload.php

# App dir (named volume at runtime)
RUN mkdir -p /var/www/html/sentrifugo && chown -R www-data:www-data /var/www/html
VOLUME ["/var/www/html/sentrifugo"]

# Entrypoint seeds app on first run and applies runtime patches
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --retries=10 CMD curl -fsS http://localhost/ || exit 1

CMD ["apache2-foreground"]
